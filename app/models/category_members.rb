# frozen_string_literal: true

require 'pathname'
require 'yaml'

# 分类成员名单的读取器（Ruby 侧）。
#
# 为什么需要它，以及为什么这是一件有风险的事
# ------------------------------------------
# 落点 11 的诊断需要「同类成员名单」。名单的来源是 `compass-projects-information`
# 的 `collections/*.yml`。而本工程在 metrics-model 侧**已经有一个读取器**
# （`category_scopes.py`），它的规则是被实测修正过的：YAML 解析、去掉尾斜杠、
# `http://` 改 `https://`、去重。
#
# 在 Ruby 侧再写一份，就构成**同一件事有两套解析规则**——而规则分家正是本工程
# 记录过的缺陷：更早的分析产物用逐行切前缀而不用 YAML 解析器，把注释文字当成了
# URL 的一部分，比真实实现多出 186 个永不可能匹配的 URL，另缺失 133 个干净 URL。
#
# 既然必须写第二份，就用两条措施把它管住：
#   1. **逐条对齐**：本文件的归一化与校验规则逐条抄自 `category_scopes.py`，
#      连报错条件都对齐（缺 ident、items 不是列表、非字符串项、归一化后为空、
#      ident 重复、目录不存在、目录里没有 *.yml，全部**抛错**而不是静默跳过）；
#   2. **一致性门禁**：`tests/category_stats/test_category_members_consistency.py`
#      用**真实名单**逐项比对 Ruby 与 Python 两侧的输出（同样的 ident 集合、
#      同样的 URL 列表、同样的顺序）。任一侧改规则而另一侧没跟上，门禁立刻变红。
#
# 读不到名单时**抛错**。静默返回空名单会让每一个分类都变成「样本不足」，
# 界面看起来正常但全是空的——那是本工程一直在防的那类缺陷。
module CategoryMembers
  # 名单目录由环境变量给出，命名与 metrics-model 侧的配置键 collections_dir 对应。
  ENV_KEY = 'CATEGORY_COLLECTIONS_DIR'

  class Error < StandardError; end

  class << self
    # 读目录，返回有序的 { ident => [url, ...] }。
    def load(directory = nil)
      directory = resolve_directory(directory)
      dir = Pathname.new(directory.to_s)
      raise Error, "分类名单目录不存在：#{dir}" unless dir.directory?

      files = Dir.glob(dir.join('*.yml').to_s).sort
      raise Error, "分类名单目录里没有任何 *.yml：#{dir}" if files.empty?

      scopes = {}
      files.each do |file|
        name = File.basename(file)
        data = parse(file, name)
        ident = data['ident']
        items = data['items']

        unless ident.is_a?(String) && !ident.empty?
          raise Error, "分类文件缺少合法的 ident：#{name}"
        end
        raise Error, "分类文件的 items 不是列表：#{name}" unless items.is_a?(Array)
        raise Error, "分类 ident 重复：#{ident}（#{name}）" if scopes.key?(ident)

        seen = {}
        scopes[ident] = items.each_with_object([]) do |raw, acc|
          raise Error, "分类的 items 里有非字符串项：#{name}（#{raw.inspect}）" unless raw.is_a?(String)

          url = normalize_url(raw)
          raise Error, "分类的 items 里有空项：#{name}" if url.empty?
          next if seen[url]

          seen[url] = true
          acc << url
        end
      end
      scopes
    end

    # 取某个分类的成员；分类不存在时**抛错**。
    #
    # 不返回空数组：空数组会被上层算成「样本不足」，界面显示为正常的一页空表，
    # 而真正的原因是分类名写错了。写错的名字必须看得见。
    def for_category(ident, directory = nil)
      scopes = load(directory)
      return scopes[ident] if scopes.key?(ident)

      raise Error, "分类名单里没有这个分类：#{ident}"
    end

    # 单个 URL 的归一化。逐条对齐 `category_scopes.py` 的 normalize_url：
    #   1. 去首尾空白；2. 去掉**全部**尾斜杠；3. `http://` 改 `https://`。
    # 为什么第 3 条必须做：名单里有 145 个 `http://` 条目，而指标文档的 `label`
    # 用 https，不改协议这 145 个项目永远匹配不上。
    def normalize_url(raw)
      url = raw.to_s.strip.sub(%r{/+\z}, '')
      url = "https://#{url['http://'.length..]}" if url.start_with?('http://')
      url
    end

    def resolve_directory(directory = nil)
      directory || ENV[ENV_KEY]
    end

    private

    def parse(file, name)
      data = YAML.safe_load(File.read(file, encoding: 'UTF-8'))
      raise Error, "分类文件内容不是映射：#{name}" unless data.is_a?(Hash)

      data
    rescue Psych::SyntaxError => e
      raise Error, "分类文件无法解析：#{name}（#{e.message}）"
    end
  end
end
