# frozen_string_literal: true

module Openapi
  module V2
    module Star
      class StarV2ProjectServer < Grape::API
        # 整响应缓存（Redis，快照/指标类 1 小时、活动计数类 15 分钟）
        use Openapi::V2::Star::ResponseCacheMiddleware

        version 'v2', using: :path
        prefix :api
        format :json

        before do
          # require_login!
        end

        helpers do
          # ---------- 通用工具 ----------

          # 拆分 "url1,url2" / "url1; url2" / 空白分隔 为原子 URL 数组
          def parse_project_urls(raw)
            Array(raw).flat_map { |r| r.to_s.split(/[,;\s]+/) }.map(&:strip).reject(&:empty?)
          end

          # 根据 repo_url 获取社区名称（StarProject 表）
          def get_community_name(keyword)
            k = keyword.to_s.chomp('/')
            StarProject.find_by(repo_url: k)&.project_name ||
              StarProject.where(repo_url: "#{k}/").limit(1).pick(:project_name)
          end

          # 将单个原子 URL 展开为底层仓库 URL 列表（社区 URL 展开，普通 repo 原样返回）
          # 本地 Subject 表展开社区：community -> 子仓库列表
          # 优先 SubjectRef 父子关系；refs 未写入时按社区 URL 前缀兜底（label LIKE 'url/%'）
          def community_repos_from_subject(label, url = nil)
            return [] if label.blank?

            subject = Subject.find_by(label: label, level: 'community')
            return [] unless subject

            child_ids = SubjectRef.where(parent_id: subject.id).pluck(:child_id)
            repos = Subject.where(id: child_ids, level: 'repo').pluck(:label)
            return repos if repos.any?

            prefix_base = (url || subject.label).to_s
            return [] unless prefix_base =~ %r{\Ahttps?://}

            Subject.where(level: 'repo').where('label LIKE ?', prefix_base.chomp('/') + '/%').pluck(:label)
          end

          # 社区入参支持三种形式：社区 URL（单段 path）/ 社区名（Subject label，大小写不敏感）/ star_projects 登记名
          def expand_to_repo_urls(url)
            path_parts = begin
              URI.parse(url).path.split('/').reject(&:empty?)
            rescue URI::InvalidURIError
              []
            end
            return [url.chomp('/')] if path_parts.size > 1

            # 社区名：URL 入参取 star_projects 登记的社区名；名字入参反查 star_projects 拿社区 URL
            label = get_community_name(url) || url
            community_url = StarProject.where(project_name: url).pick(:repo_url).presence || url

            # 仅本地 Subject 表展开（SubjectRef 父子关系 → URL 前缀兜底）；
            # 不走 director 服务（远端不可达时其 60s 超时会挂住请求线程）
            repos = community_repos_from_subject(label, community_url.chomp('/'))
            repos = community_repos_from_subject(community_url.chomp('/')) if repos.blank?
            repos.present? ? repos : [url]
          end

          # 入参项目列表 → 去重后的底层仓库 URL 列表
          def expand_inputs(project_urls)
            parse_project_urls(project_urls).flat_map { |u| expand_to_repo_urls(u) }.uniq
          end

          # 入参分组展开：[[原始入参地址, [展开后仓库列表]], ...]
          # 社区地址保持一条（返回时不拆分成仓库），仓库地址即自身；结果缓存 15 分钟（省去每请求的展开 SQL）
          def expand_inputs_grouped(project_urls)
            parse_project_urls(project_urls).map do |u|
              key = "star_v2:expand:#{Digest::MD5.hexdigest(u)}"
              repos = Rails.cache.fetch(key, expires_in: 15.minutes) { expand_to_repo_urls(u) }
              [u, repos]
            end
          end

          # 按平台分组，返回 [[indexer_class, urls], ...]
          def platform_groups(repo_urls, gitee_idx, github_idx, gitcode_idx = nil)
            gitcode_idx ||= github_idx
            [
              [github_idx, repo_urls.select { |u| u.include?('github.com') }],
              [gitee_idx, repo_urls.select { |u| u.include?('gitee.com') }],
              [gitcode_idx, repo_urls.select { |u| u.include?('gitcode.com') }]
            ].reject { |_, urls| urls.empty? }
          end

          # 对每个平台分组执行 block 并求和
          def sum_over_platforms(repo_urls, gitee_idx, github_idx, gitcode_idx = nil)
            platform_groups(repo_urls, gitee_idx, github_idx, gitcode_idx).sum { |idx, urls| yield(idx, urls).to_i }
          end

          # 起止时间（默认近两年）
          def time_range
            begin_date = params[:start_time] || params[:begin_date] || 2.years.ago.utc
            end_date = params[:end_time] || Time.now.utc
            [begin_date, end_date]
          end

          # 时间类型归一化：week / month / year
          def period_type
            (params[:time_type] || 'week').to_s.downcase
          end

          # 将 [{date:, value:}] 按周期聚合；sum 为 true 累加，false 取周期内最新值
          def aggregate_period(items, time_type, sum: true)
            sorted = items.sort_by { |i| Time.parse(i[:date].to_s) }
            case time_type
            when 'year'
              sorted.group_by { |i| Time.parse(i[:date].to_s).year }
                    .map do |y, rows|
                { date: Date.new(y, 12, 31).to_s,
                  value: sum ? rows.sum { |r| r[:value].to_i } : rows.max_by { |r| Time.parse(r[:date].to_s) }[:value] }
              end
            when 'month'
              sorted.group_by { |i| t = Time.parse(i[:date].to_s); [t.year, t.month] }
                    .map do |(y, m), rows|
                { date: Date.new(y, m, -1).to_s,
                  value: sum ? rows.sum { |r| r[:value].to_i } : rows.max_by { |r| Time.parse(r[:date].to_s) }[:value] }
              end
            when 'week'
              sorted.group_by { |i| d = Time.parse(i[:date].to_s).to_date; [d.cwyear, d.cweek] }
                    .map do |(y, w), rows|
                { date: Date.commercial(y, w, 7).to_s,
                  value: sum ? rows.sum { |r| r[:value].to_i } : rows.max_by { |r| Time.parse(r[:date].to_s) }[:value] }
              end
            else
              # 默认按周聚合
              sorted.group_by { |i| d = Time.parse(i[:date].to_s).to_date; [d.cwyear, d.cweek] }
                    .map do |(y, w), rows|
                { date: Date.commercial(y, w, 7).to_s,
                  value: sum ? rows.sum { |r| r[:value].to_i } : rows.max_by { |r| Time.parse(r[:date].to_s) }[:value] }
              end
            end
          end

          # Scroll 拉取指定字段原始记录（string key），返回 _source 数组
          def scroll_sources(indexer, repo_urls, begin_date, end_date, fields, target: 'tag', date_field: :grimoire_creation_date)
            all = []
            query = indexer
                      .must(terms: { target => repo_urls })
                      .range(date_field, gte: begin_date, lt: end_date)
                      .sort(date_field => :asc)
                      .source(fields)
            query.find_results_in_batches(batch_size: 1000) do |batch|
              batch.each { |src| all << src }
            end
            all
          end

          # 用 date_histogram 聚合按周期统计 commit 数、新增/删除行数与华为提交数
          # 过滤口径与 commit 统计一致（排除机器人/merge 提交，可选分支），GitEnrich 的 tag 带 .git 后缀
          # 返回 { repo_url => [{ date:, commits:, lines_added:, lines_removed:, huawei_commits: }] }
          def commit_count_period_data(indexer, repo_urls, begin_date, end_date, time_type, branch = nil)
            interval = { 'year' => 'year', 'month' => 'month', 'week' => 'week' }[time_type] || 'week'
            git_urls = repo_urls.map { |u| u.sub(/\.git\z/, '') + '.git' }
            base = indexer
                     .must(terms: { 'tag' => git_urls })
                     .must(wildcard: { author_email: { value: '*@*' } })
                     .must(wildcard: { committer_email: { value: '*@*' } })
                     .must(range: { lines_changed: { gt: 0 } })
                     .must_not(terms: { author_email: ['mamingshuai@huawei.com', 'wenjun1@huawei.com'] })
                     .must_not(terms: { committer_email: ['mamingshuai@huawei.com', 'wenjun1@huawei.com'] })
                     .must_not(wildcard: { author_email: { value: '*noreply*' } })
                     .must_not(wildcard: { committer_email: { value: '*noreply*' } })
                     .must_not(wildcard: { message: { value: '*Merge pull request*' } })
                     .range(:grimoire_creation_date, gte: begin_date, lt: end_date)
            base = base.must(match_phrase: { branches: "'#{branch}'" }) if branch.present?

            resp = base
                     .per(0)
                     .aggregate(
                       by_repo: {
                         terms: { field: 'tag', size: git_urls.length + 100 },
                         aggs: {
                           over_time: {
                             date_histogram: { field: :grimoire_creation_date, calendar_interval: interval, min_doc_count: 1 },
                             aggs: {
                               lines_added: { sum: { field: 'lines_added' } },
                               lines_removed: { sum: { field: 'lines_removed' } },
                               huawei: { filter: { terms: { author_domain: huawei_domains } } }
                             }
                           }
                         }
                       }
                     )
                     .execute
                     .raw_response
            result = {}
            (resp.dig('aggregations', 'by_repo', 'buckets') || []).each do |rb|
              repo = rb['key'].to_s.sub(/\.git\z/, '')
              result[repo] = (rb.dig('over_time', 'buckets') || []).map do |b|
                raw_date = b['key_as_string'] || Time.at(b['key'].to_i / 1000).to_date.to_s
                { date: period_key(raw_date, time_type), commits: b['doc_count'],
                  lines_added: b.dig('lines_added', 'value').to_i,
                  lines_removed: b.dig('lines_removed', 'value').to_i,
                  huawei_commits: b.dig('huawei', 'doc_count').to_i }
              end
            end
            result
          end

          # 按仓库统计 commit 数（总数 / 华为），一次聚合按 tag 分桶 + 华为 domain 过滤子聚合
          # 返回 { repo_url => { total:, huawei: } }
          def commit_counts_by_repo(indexer, repo_urls, begin_date, end_date, branch)
            result = Hash.new { |h, k| h[k] = { total: 0, huawei: 0 } }
            return result if repo_urls.empty?

            hw_domains = huawei_domains
            git_urls = repo_urls.map { |u| u.sub(/\.git\z/, '') + '.git' }
            base = indexer
                     .must(terms: { 'tag' => git_urls })
                     .must(wildcard: { author_email: { value: '*@*' } })
                     .must(wildcard: { committer_email: { value: '*@*' } })
                     .must(range: { lines_changed: { gt: 0 } })
                     .must_not(terms: { author_email: ['mamingshuai@huawei.com', 'wenjun1@huawei.com'] })
                     .must_not(terms: { committer_email: ['mamingshuai@huawei.com', 'wenjun1@huawei.com'] })
                     .must_not(wildcard: { author_email: { value: '*noreply*' } })
                     .must_not(wildcard: { committer_email: { value: '*noreply*' } })
                     .must_not(wildcard: { message: { value: '*Merge pull request*' } })
                     .range(:grimoire_creation_date, gte: begin_date, lt: end_date)
            base = base.must(match_phrase: { branches: "'#{branch}'" }) if branch.present?

            resp = base
                     .per(0)
                     .aggregate(
                       by_repo: {
                         terms: { field: 'tag', size: git_urls.length + 100 },
                         aggs: {
                           huawei: { filter: { terms: { author_domain: hw_domains } } }
                         }
                       }
                     )
                     .execute
                     .raw_response
            (resp&.[]('aggregations')&.[]('by_repo')&.[]('buckets') || []).each do |b|
              repo = b['key'].to_s.sub(/\.git\z/, '')
              result[repo][:total] += b['doc_count'].to_i
              result[repo][:huawei] += b.dig('huawei', 'doc_count').to_i
            end
            result
          end

          # 华为对应的 author_domain 列表（Organization 索引缓存）
          def huawei_domains
            @huawei_domains ||= Rails.cache.fetch('star_v2:huawei_domains', expires_in: 1.day) do
              terms = %w[Huawei huawei HUAWEI]
              Organization.must(terms: { 'org_name.keyword' => terms }).per(10_000).execute.raw_response
                          .dig('hits', 'hits').to_a.map { |h| h.dig('_source', 'domain') }.compact.uniq
            end
          end

          # 分页查询（带精确总数 count）：track_total_hits(true) 解除 ES 1 万条统计上限
          # 等价于 terms_by_repo_urls，但返回 {"hits" => {"total" => {"value" => 精确总数}, "hits" => [...]}}
          def paged_terms(indexer, repo_urls, begin_date, end_date, page:, size:,
                          target: 'tag', filter: :created_at, sort: :created_at)
            indexer
              .must(terms: { target => repo_urls })
              .range(filter, gte: begin_date, lt: end_date)
              .sort(sort => :asc)
              .page(page.to_i)
              .per(size.to_i)
              .track_total_hits(true)
              .execute
              .raw_response
          end

          # 将任意时间字符串归一化为周期结束日期（周末/月末/年末），保证 new 与 total 的日期对齐
          def period_key(date_str, time_type)
            t = Time.parse(date_str.to_s)
            case time_type
            when 'year' then Date.new(t.year, 12, 31).to_s
            when 'month' then Date.new(t.year, t.month, -1).to_s
            else Date.commercial(t.to_date.cwyear, t.to_date.cweek, 7).to_s
            end
          end

          # 每个周期时间窗口内，各 URL 最新一条快照值（作为该周期的 total）
          # 查询不设下界（需要范围前的快照做基线），返回 { repo_url => { "2026-09-30" => total, ... } }
          # 每个周期时间窗口内各仓库最新快照值；baseline 为起始时间前每仓库最近一次快照值。
          # histogram 只查 [begin, end)（防止大社区全历史周桶数超 ES max_buckets），基线用 filter+top_hits 单独取
          # 返回 { repo_url => { totals: { "2026-09-30" => v }, baseline: v } }
          def repo_snapshot_period(repo_urls, field, begin_date, end_date, time_type)
            interval = { 'year' => 'year', 'month' => 'month' }[time_type] || 'week'
            result = Hash.new { |h, k| h[k] = { totals: Hash.new(0), baseline: 0 } }
            platform_groups(repo_urls, GiteeRepoEnrich, GithubRepoEnrich, GitcodeRepoEnrich).each do |idx, urls|
              resp = idx
                       .must(terms: { 'tag' => urls })
                       .per(0)
                       .aggregate(
                         by_repo: {
                           terms: { field: 'tag', size: urls.length + 100 },
                           aggs: {
                             baseline: {
                               filter: { range: { grimoire_creation_date: { lt: begin_date } } },
                               aggs: {
                                 latest: {
                                   top_hits: {
                                     size: 1,
                                     sort: [{ grimoire_creation_date: { order: 'desc' } }],
                                     _source: { includes: [field] }
                                   }
                                 }
                               }
                             },
                             in_range: {
                               filter: { range: { grimoire_creation_date: { gte: begin_date, lt: end_date } } },
                               aggs: {
                                 over_time: {
                                   date_histogram: { field: :grimoire_creation_date, calendar_interval: interval, min_doc_count: 1 },
                                   aggs: {
                                     latest: {
                                       top_hits: {
                                         size: 1,
                                         sort: [{ grimoire_creation_date: { order: 'desc' } }],
                                         _source: { includes: [field] }
                                       }
                                     }
                                   }
                                 }
                               }
                             }
                           }
                         }
                       )
                       .execute
                       .raw_response
              (resp.dig('aggregations', 'by_repo', 'buckets') || []).each do |rb|
                repo = rb['key']
                result[repo][:baseline] += rb.dig('baseline', 'latest', 'hits', 'hits', 0, '_source', field).to_i
                (rb.dig('in_range', 'over_time', 'buckets') || []).each do |b|
                  date = period_key(b['key_as_string'], time_type)
                  value = b.dig('latest', 'hits', 'hits', 0, '_source', field).to_i
                  result[repo][:totals][date] += value
                end
              end
            end
            result
          end

          # 下一个周期的结束日期（date 为当前周期结束日期）
          def next_period_end(date, time_type)
            case time_type
            when 'year' then Date.new(date.year + 1, 12, 31)
            when 'month' then Date.new(date.next_month.year, date.next_month.month, -1)
            else date + 7 # week：date 为周日
            end
          end

          # 组级快照周期序列（社区=多个仓库）：各仓库分别前向填充后按周期求和，
          # new 为组级差值（截 0），repo_url 为原始入参地址（社区地址）
          # totals_by_repo 结构：{ repo => { totals: { 周期 => 值（范围内） }, baseline: 起始前最近快照值 } }
          def group_snapshot_series(input_url, repos, totals_by_repo, begin_date, end_date, time_type)
            entries = repos.filter_map do |r|
              e = totals_by_repo[r]
              next if e.nil?
              next if e[:baseline].to_i.zero? && e[:totals].empty?
              e
            end
            return { repo_url: input_url, items: [] } if entries.empty?

            # 起始周期统一取 begin_date 所在周期（与 issue/pr/commit 周期接口一致）：
            # 首周期无快照时 new=0、total=基线值，保证时间轴从 start_time 开始连续
            first_period = period_key(begin_date.to_s, time_type)
            ladder = [first_period]
            cursor = Date.parse(first_period)
            last_period = Date.parse(period_key((end_date - 1.day).to_s, time_type)) # 左闭右开：截止周期取 end 前一天所在周期（end 为周期首日时不含该周期）
            while (cursor = next_period_end(cursor, time_type)) <= last_period
              ladder << cursor.to_s
            end

            # 每个仓库在阶梯各周期的填充值（基线 = 起始时间前该仓库最近一次快照）
            filled = entries.map do |e|
              current = e[:baseline]
              ladder.each_with_object({}) do |d, arr|
                current = e[:totals][d] if e[:totals].key?(d)
                arr[d] = current
              end
            end

            # prev_total 起点 = 起始时刻的基线存量之和（各仓库 begin 前最近一次快照之和），
            # 这样首个周期的 new_count 才是「首周期内的真实增量」，而非累计存量
            baseline_total = entries.sum { |e| e[:baseline] }
            prev_total = baseline_total
            items = ladder.map do |d|
              total = filled.sum { |f| f[d] }
              new_count = total - prev_total
              new_count = 0 if new_count < 0
              prev_total = total
              { date: d, new_count: new_count, total_count: total }
            end

            { repo_url: input_url, items: items }
          end

          # issue 周期序列：created/close 为周期内数量（created 按创建时间、close 按关闭时间归期），
          # total 为从项目起始累计到该周期截止的创建总数（上期 total + 本期 created = 本期 total），
          # unclosed 为截至该周期的未关闭数（累计创建 − 累计关闭，负数截 0）
          # opened/closed 为 [begin, end) 内的周期数据；opened_baseline/closed_baseline 为起始前累计数（调用方传入）
          def issue_period_series(repo_url, opened_by_date, closed_by_date, begin_date, end_date, time_type,
                                  opened_baseline: 0, closed_baseline: 0, unclosed_exact: nil)
            all_dates = (opened_by_date.keys | closed_by_date.keys).sort_by { |d| Time.parse(d) }
            # 输出周期：范围内无数据时从 begin 所在周期补 0 到 end 前一天所在周期（total/unclosed 用基线延续）；
            # 有数据时从首个有数据周期起补齐（左闭右开）
            first_period = all_dates.empty? ? period_key(begin_date.to_s, time_type) : all_dates.first
            prev_created = all_dates.empty? ? opened_baseline : opened_baseline
            prev_closed = closed_baseline
            in_range = all_dates

            dates = [first_period]
            cursor = Date.parse(first_period)
            last_period = Date.parse(period_key((end_date - 1.day).to_s, time_type))
            while (cursor = next_period_end(cursor, time_type)) <= last_period
              dates << cursor.to_s
            end

            items = dates.map do |d|
              created = opened_by_date[d] || 0
              closed = closed_by_date[d] || 0
              prev_created += created
              prev_closed += closed
              unclosed = prev_created - prev_closed
              unclosed = 0 if unclosed < 0 # 数据不一致导致为负时截为 0
              { date: d, issue_created_count: created, issue_close_count: closed,
                issue_unclosed_count: unclosed, issue_total_count: prev_created }
            end

            # 末周期的 unclosed 用精确存量（当前 state=open），与 issue_count 口径一致；
            # 中间历史周期无法还原当时状态，仍用「累计创建 − 累计关闭」重构值
            if unclosed_exact && items.any?
              items.last[:issue_unclosed_count] = unclosed_exact
            end
            # 无数据时补的 0 行：total 保持基线（存量延续），unclosed 也保持基线
            if all_dates.empty?
              items.each do |i|
                i[:issue_total_count] = prev_created
                i[:issue_unclosed_count] = unclosed_exact || (prev_created - prev_closed)
              end
            end

            { repo_url: repo_url, items: items }
          end

          # pr 周期序列：opened/closed/merged 为周期内数量（分别按创建/关闭/合并时间归期），
          # total 为从项目起始累计到该周期截止的创建总数（上期 total + 本期 opened = 本期 total）
          def pr_period_series(repo_url, opened_by_date, closed_by_date, merged_by_date, begin_date, end_date, time_type,
                               opened_baseline: 0)
            all_dates = (opened_by_date.keys | closed_by_date.keys | merged_by_date.keys).sort_by { |d| Time.parse(d) }
            return { repo_url: repo_url, items: [] } if all_dates.empty?

            # opened/closed/merged 已是 [begin, end) 内的周期数据；基线为起始前累计创建数（由调用方传入）
            in_range = all_dates
            prev_total = opened_baseline

            # 输出周期：从范围内首个有数据周期起，逐周期补齐到 end_date 所在周期
            dates = [in_range.first]
            cursor = Date.parse(in_range.first)
            last_period = Date.parse(period_key((end_date - 1.day).to_s, time_type)) # 左闭右开：截止周期取 end 前一天所在周期（end 为周期首日时不含该周期）
            cursor = next_period_end(cursor, time_type)
            while cursor <= last_period
              dates << cursor.to_s
              cursor = next_period_end(cursor, time_type)
            end

            items = dates.map do |d|
              opened = opened_by_date[d] || 0
              prev_total += opened
              { date: d, pr_opened_count: opened, pr_closed_count: closed_by_date[d] || 0,
                pr_merged_count: merged_by_date[d] || 0, pr_total_count: prev_total }
            end

            { repo_url: repo_url, items: items }
          end

          # 按 label 聚合，每个 label 取时间范围内最新一条的指定字段值
          # 指数字段组装：原始分（0-1）+ 百分制（平台分段换算 BaseMetric.scaled_value，0-100 整数）
          def index_score_fields(activity, community, codequality, org_activity)
            {
              activity_score: activity,
              activity_transformed_score: activity.present? ? ActivityMetric.scaled_value(nil, target_value: activity) : nil,
              community_support_score: community,
              community_support_transformed_score: community.present? ? CommunityMetric.scaled_value(nil, target_value: community) : nil,
              code_quality_guarantee: codequality,
              code_quality_transformed_score: codequality.present? ? CodequalityMetric.scaled_value(nil, target_value: codequality) : nil,
              organizations_activity: org_activity,
              organizations_activity_transformed_score: org_activity.present? ? GroupActivityMetric.scaled_value(nil, target_value: org_activity) : nil
            }
          end

          # 指标原始快照序列：时间范围内全部数据点，按快照日期（天）返回，同日多条取最新
          # 返回 { label => { "2026-09-07" => score } }
          def metric_snapshot_series(indexer, labels, field, begin_date, end_date)
            result = Hash.new { |h, k| h[k] = {} }
            return result if labels.blank?

            resp = indexer
                     .must(terms: { 'label.keyword' => labels })
                     .range(:grimoire_creation_date, gte: begin_date, lt: end_date)
                     .per(0)
                     .aggregate(
                       by_label: {
                         terms: { field: 'label.keyword', size: labels.length + 20 },
                         aggs: {
                           over_time: {
                             date_histogram: { field: :grimoire_creation_date, calendar_interval: 'day', min_doc_count: 1 },
                             aggs: {
                               latest: {
                                 top_hits: {
                                   size: 1,
                                   sort: [{ grimoire_creation_date: { order: 'desc' } }],
                                   _source: { includes: [field] }
                                 }
                               }
                             }
                           }
                         }
                       }
                     )
                     .execute
                     .raw_response
            (resp&.[]('aggregations')&.[]('by_label')&.[]('buckets') || []).each do |lb|
              (lb.dig('over_time', 'buckets') || []).each do |b|
                hit = b.dig('latest', 'hits', 'hits', 0, '_source')
                next unless hit

                result[lb['key']][b['key_as_string'].to_s[0, 10]] = hit[field]
              end
            end
            result
          end

          def get_index_last_data_agg(base_indexer, urls, field, begin_date, end_date)
            safe_urls = Array(urls).flatten.compact.uniq.reject(&:blank?)
            return [] if safe_urls.empty?

            source_fields = field.is_a?(Array) ? field : [field]

            criteria = base_indexer
                         .must(terms: { 'label.keyword' => safe_urls })
                         .range(:grimoire_creation_date, gte: begin_date, lt: end_date)
                         .per(0)

            criteria = criteria.aggregate(
              projects_group: {
                terms: { field: 'label.keyword', size: safe_urls.length + 20 },
                aggs: {
                  latest_record: {
                    top_hits: {
                      size: 1,
                      sort: [{ grimoire_creation_date: { order: 'desc' } }],
                      _source: { includes: source_fields }
                    }
                  }
                }
              }
            )

            begin
              raw_aggs = criteria.aggregations
              buckets = raw_aggs.dig('projects_group', 'buckets') || []

              buckets.map do |bucket|
                hits_container = bucket.dig('latest_record', 'hits', 'hits')
                next unless hits_container && hits_container.first

                hit_source = hits_container.first['_source']
                entry = { label: bucket['key'] }
                source_fields.each do |f|
                  next if f.to_s == 'label'
                  entry[f.to_sym] = hit_source[f.to_s]
                end
                entry
              end.compact
            rescue SearchFlip::ResponseError => e
              Rails.logger.error("【ES Error】get_index_last_data_agg failed: #{e.message}")
              []
            end
          end

          # 华为 / 非华为 判定
          def huawei?(org)
            org.to_s.downcase.include?('huawei')
          end
        end

        resource :star_v2_project_server do
          # ============ A2 Fork 周期内 fork 数 ============
          desc '周期内 fork 数统计（new + total）', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :time_type, type: String, desc: '时间类型 week/month/year', default: 'week'
          end
          post :fork_count_period do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range
            time_type = period_type

            # 以快照为准：total 为周期内最新快照值，new 为相邻周期快照差值（净新增）；
            # 社区（多仓库）各仓库前向填充后按周期求和，返回一条
            total_by_repo = repo_snapshot_period(repo_urls, 'forks_count', begin_date, end_date, time_type)

            data = groups.map do |input, repos|
              group_snapshot_series(input, repos, total_by_repo, begin_date, end_date, time_type)
            end

            { code: 201, data: { fork_count: data } }
          end

          # ============ A3 Fork 某个时间范围 fork 数量 ============
          desc '某个时间范围项目 fork 数量', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
          end
          post :fork_count do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range

            # 直接取 repo 快照（*RepoEnrich）：时间范围内每个仓库最新一条的 forks_count
            count_by_repo = {}
            platform_groups(repo_urls, GiteeRepoEnrich, GithubRepoEnrich, GitcodeRepoEnrich).each do |idx, urls|
              resp = idx
                       .must(terms: { 'tag' => urls })
                       .range(:grimoire_creation_date, gte: begin_date, lt: end_date)
                       .per(0)
                       .aggregate(
                         by_repo: {
                           terms: { field: 'tag', size: urls.length + 100 },
                           aggs: {
                             latest: {
                               top_hits: {
                                 size: 1,
                                 sort: [{ grimoire_creation_date: { order: 'desc' } }],
                                 _source: { includes: ['forks_count'] }
                               }
                             }
                           }
                         }
                       )
                       .execute
                       .raw_response
              (resp.dig('aggregations', 'by_repo', 'buckets') || []).each do |b|
                hit = b.dig('latest', 'hits', 'hits', 0, '_source')
                count_by_repo[b['key']] = hit['forks_count'].to_i if hit
              end
            end

            data = groups.map { |input, repos| { repo_url: input, fork_count: repos.sum { |r| count_by_repo[r] || 0 } } }

            { code: 201, data: { fork_count: data } }
          end

          # ============ A4 Star 周期内 star 数 ============
          desc '周期内 star 数统计（new + total）', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :time_type, type: String, desc: '时间类型 week/month/year', default: 'week'
          end
          post :star_count_period do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range
            time_type = period_type

            # 以快照为准：total 为周期内最新快照值，new 为相邻周期快照差值（净新增）；
            # 社区（多仓库）各仓库前向填充后按周期求和，返回一条
            total_by_repo = repo_snapshot_period(repo_urls, 'stargazers_count', begin_date, end_date, time_type)

            data = groups.map do |input, repos|
              group_snapshot_series(input, repos, total_by_repo, begin_date, end_date, time_type)
            end

            { code: 201, data: { star_count: data } }
          end

          # ============ A5 Star 某个时间范围 star 数量 ============
          desc '某个时间范围项目 star 数量', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
          end
          post :star_count do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range

            # 直接取 repo 快照（*RepoEnrich）：时间范围内每个仓库最新一条的 stargazers_count
            count_by_repo = {}
            platform_groups(repo_urls, GiteeRepoEnrich, GithubRepoEnrich, GitcodeRepoEnrich).each do |idx, urls|
              resp = idx
                       .must(terms: { 'tag' => urls })
                       .range(:grimoire_creation_date, gte: begin_date, lt: end_date)
                       .per(0)
                       .aggregate(
                         by_repo: {
                           terms: { field: 'tag', size: urls.length + 100 },
                           aggs: {
                             latest: {
                               top_hits: {
                                 size: 1,
                                 sort: [{ grimoire_creation_date: { order: 'desc' } }],
                                 _source: { includes: ['stargazers_count'] }
                               }
                             }
                           }
                         }
                       )
                       .execute
                       .raw_response
              (resp.dig('aggregations', 'by_repo', 'buckets') || []).each do |b|
                hit = b.dig('latest', 'hits', 'hits', 0, '_source')
                count_by_repo[b['key']] = hit['stargazers_count'].to_i if hit
              end
            end

            data = groups.map { |input, repos| { repo_url: input, star_count: repos.sum { |r| count_by_repo[r] || 0 } } }

            { code: 201, data: { star_count: data } }
          end

          # ============ A6 Issue open/close/total 数 ============
          desc '某个时间范围项目 Issue open 数、close 数、总数', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
          end
          post :issue_count do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range

            # 按仓库统计：open = 范围内创建数（按 created_at，不看状态），
            # close = 范围内关闭动作数（按 closed_at，动作发生时间），
            # unclosed = 截至结束时间仍未关闭的存量（创建 ≤ end 且当前 state=open，含范围前创建的）
            stats = Hash.new { |h, k| h[k] = { open: 0, closed: 0, unclosed: 0 } }
            platform_groups(repo_urls, GiteeIssueEnrich, GithubIssueEnrich, GitcodeIssueEnrich).each do |idx, urls|
              resp = idx
                       .must(terms: { 'tag' => urls })
                       .per(0)
                       .aggregate(
                         by_repo: {
                           terms: { field: 'tag', size: urls.length + 100 },
                           aggs: {
                             open: { filter: { range: { created_at: { gte: begin_date, lt: end_date } } } },
                             closed: { filter: { range: { closed_at: { gte: begin_date, lt: end_date } } } },
                             unclosed: {
                               filter: {
                                 bool: {
                                   must: [
                                     { range: { created_at: { lt: end_date } } },
                                     { term: { state: 'open' } }
                                   ]
                                 }
                               }
                             }
                           }
                         }
                       )
                       .execute
                       .raw_response
              (resp.dig('aggregations', 'by_repo', 'buckets') || []).each do |b|
                stats[b['key']][:open] += b.dig('open', 'doc_count').to_i
                stats[b['key']][:closed] += b.dig('closed', 'doc_count').to_i
                stats[b['key']][:unclosed] += b.dig('unclosed', 'doc_count').to_i
              end
            end

            data = groups.map do |input, repos|
              s = { open: 0, closed: 0, unclosed: 0 }
              repos.each do |r|
                s[:open] += stats[r][:open]
                s[:closed] += stats[r][:closed]
                s[:unclosed] += stats[r][:unclosed]
              end
              { repo_url: input, issue_open_count: s[:open], issue_close_count: s[:closed],
                issue_total_count: s[:open], issue_unclosed_count: s[:unclosed] }
            end

            { code: 201, data: { issue_count: data } }
          end

          # ============ A7 Issue 周期 open/close/total/unclosed ============
          desc '周期内 Issue open/close/total/unclosed 数', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :time_type, type: String, desc: '时间类型 week/month/year', default: 'week'
          end
          post :issue_count_period do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range
            time_type = period_type
            interval = { 'year' => 'year', 'month' => 'month' }[time_type] || 'week'

            # 按仓库聚合：created 按创建时间、close 按关闭时间分周期（histogram 只查 [begin, end)，
            # 防止大社区全历史周期桶数超 ES max_buckets）；起始前累计基线用 filter count 单独取
            opened_by_repo = Hash.new { |h, k| h[k] = Hash.new(0) }
            closed_by_repo = Hash.new { |h, k| h[k] = Hash.new(0) }
            opened_before = Hash.new(0)
            closed_before = Hash.new(0)
            unclosed_exact = Hash.new(0) # 当前仍 open 且 created < end 的精确存量（末周期用）

            platform_groups(repo_urls, GiteeIssueEnrich, GithubIssueEnrich, GitcodeIssueEnrich).each do |idx, urls|
              resp = idx
                       .must(terms: { 'tag' => urls })
                       .per(0)
                       .aggregate(
                         by_repo: {
                           terms: { field: 'tag', size: urls.length + 100 },
                           aggs: {
                             opened_before: { filter: { range: { created_at: { lt: begin_date } } } },
                             closed_before: {
                               filter: { bool: { must: [{ term: { state: 'closed' } }, { range: { closed_at: { lt: begin_date } } }] } }
                             },
                             opened: {
                               filter: { range: { created_at: { gte: begin_date, lt: end_date } } },
                               aggs: { over_time: { date_histogram: { field: :created_at, calendar_interval: interval, min_doc_count: 1 } } }
                             },
                             closed: {
                               filter: { bool: { must: [{ term: { state: 'closed' } }, { range: { closed_at: { gte: begin_date, lt: end_date } } }] } },
                               aggs: { over_time: { date_histogram: { field: :closed_at, calendar_interval: interval, min_doc_count: 1 } } }
                             },
                             unclosed_exact: {
                               filter: { bool: { must: [{ term: { state: 'open' } }, { range: { created_at: { lt: end_date } } }] } }
                             }
                           }
                         }
                       )
                       .execute
                       .raw_response
              (resp.dig('aggregations', 'by_repo', 'buckets') || []).each do |rb|
                repo = rb['key']
                opened_before[repo] += rb.dig('opened_before', 'doc_count').to_i
                closed_before[repo] += rb.dig('closed_before', 'doc_count').to_i
                unclosed_exact[repo] += rb.dig('unclosed_exact', 'doc_count').to_i
                (rb.dig('opened', 'over_time', 'buckets') || []).each do |b|
                  opened_by_repo[repo][period_key(b['key_as_string'], time_type)] += b['doc_count']
                end
                (rb.dig('closed', 'over_time', 'buckets') || []).each do |b|
                  closed_by_repo[repo][period_key(b['key_as_string'], time_type)] += b['doc_count']
                end
              end
            end

            data = groups.map do |input, repos|
              opened = Hash.new(0)
              closed = Hash.new(0)
              ob = 0
              cb = 0
              ue = 0
              repos.each do |r|
                (opened_by_repo[r] || {}).each { |d, v| opened[d] += v }
                (closed_by_repo[r] || {}).each { |d, v| closed[d] += v }
                ob += opened_before[r]
                cb += closed_before[r]
                ue += unclosed_exact[r]
              end
              issue_period_series(input, opened, closed, begin_date, end_date, time_type,
                                  opened_baseline: ob, closed_baseline: cb, unclosed_exact: ue)
            end

            { code: 201, data: { issue_count: data } }
          end

          # ============ A9 Issue 活动数量（创建/关闭/评论） ============
          desc '某个时间范围 issue 活动数量', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
          end
          post :issue_activity_count do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range

            # 按仓库统计活动数：创建活动按 created_at 归期，关闭活动按 closed_at（动作发生时间）归期，
            # 评论数为范围内创建的 issue 的 num_of_comments_without_bot 之和（索引无评论时间戳，按所属 issue 创建时间归入范围）
            stats = Hash.new { |h, k| h[k] = { created: 0, closed: 0, comments: 0 } }
            platform_groups(repo_urls, GiteeIssueEnrich, GithubIssueEnrich, GitcodeIssueEnrich).each do |idx, urls|
              resp = idx
                       .must(terms: { 'tag' => urls })
                       .per(0)
                       .aggregate(
                         by_repo: {
                           terms: { field: 'tag', size: urls.length + 100 },
                           aggs: {
                             created: {
                               filter: { range: { created_at: { gte: begin_date, lt: end_date } } }
                             },
                             closed: {
                               filter: { range: { closed_at: { gte: begin_date, lt: end_date } } }
                             },
                             comments: {
                               filter: { range: { created_at: { gte: begin_date, lt: end_date } } },
                               aggs: {
                                 total: { sum: { field: 'num_of_comments_without_bot' } }
                               }
                             }
                           }
                         }
                       )
                       .execute
                       .raw_response
              (resp.dig('aggregations', 'by_repo', 'buckets') || []).each do |b|
                stats[b['key']][:created] += b.dig('created', 'doc_count').to_i
                stats[b['key']][:closed] += b.dig('closed', 'doc_count').to_i
                stats[b['key']][:comments] += b.dig('comments', 'total', 'value').to_i
              end
            end

            data = groups.map do |input, repos|
              s = { created: 0, closed: 0, comments: 0 }
              repos.each { |r| s[:created] += stats[r][:created]; s[:closed] += stats[r][:closed]; s[:comments] += stats[r][:comments] }
              { repo_url: input, issue_create_count: s[:created], issue_close_count: s[:closed], issue_comment_count: s[:comments] }
            end

            { code: 201, data: { issue_activity_count: data } }
          end

          # ============ A10 Issue 元数据 ============
          desc 'Issue 元数据', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :page, type: Integer, desc: '页码', default: 1
            optional :size, type: Integer, desc: '每页条数', default: 10
          end
          post :issue_metadata do
            repo_urls = expand_inputs(params[:project_urls])
            begin_date, end_date = time_range

            items = []
            total_count = 0 # 各平台命中总数累加（分页元信息）
            # issue id -> item 引用（带平台前缀防跨平台 id 冲突），用于回填评论
            item_by_issue_id = {}
            # [item, 平台] 列表与各平台涉及的用户 login，用于回填邮箱
            items_with_platform = []
            logins_by_platform = Hash.new { |h, k| h[k] = Set.new }

            platform_groups(repo_urls, GiteeIssueEnrich, GithubIssueEnrich, GitcodeIssueEnrich).each do |idx, urls|
              resp = paged_terms(idx, urls, begin_date, end_date, page: params[:page], size: params[:size])
              total_count += resp&.[]('hits')&.[]('total')&.[]('value').to_i
              hits = resp&.[]('hits')&.[]('hits') || []
              hits.each do |data|
                s = data['_source']
                item = {
                  repo_url: s['tag'],
                  url: s['url'] || s['issue_url'],
                  title: s['title'],
                  created_at: s['created_at'],
                  author: { login: s['user_login'], name: s['author_name'], email: nil, domain: s['author_domain'], organization: s['author_org_name'] },
                  closed_at: s['closed_at'],
                  assignee: { login: s['assignee_login'], name: s['assignee_name'], email: nil, domain: s['assignee_domain'], organization: s['assignee_org_name'] },
                  state: s['state'],
                  num_of_comments: s['num_of_comments_without_bot'],
                  comments: []
                }
                items << item
                items_with_platform << [item, idx.name]
                item_by_issue_id["#{idx.name}:#{s['id_in_repo']}"] = item if s['id_in_repo'].present?
                logins_by_platform[idx.name] << s['user_login'] if s['user_login'].present?
                logins_by_platform[idx.name] << s['assignee_login'] if s['assignee_login'].present?
              end
            end

            # 评论回填：2 系列 issue 索引（gitee2/github2/gitcode2-issues_enriched）一条评论一条记录
            comment_index_by_platform = {
              'GiteeIssueEnrich' => [Gitee2IssueEnrich, repo_urls.select { |u| u.include?('gitee.com') }],
              'GithubIssueEnrich' => [Github2IssueEnrich, repo_urls.select { |u| u.include?('github.com') }],
              'GitcodeIssueEnrich' => [Gitcode2IssueEnrich, repo_urls.select { |u| u.include?('gitcode.com') }]
            }
            # 当前页涉及的仓库（而非全部入参仓库），避免大 term 数组导致超时
            page_issue_repos = Hash.new { |h, k| h[k] = Set.new }
            items_with_platform.each do |item, platform|
              page_issue_repos[platform] << item[:repo_url] if item[:repo_url]
            end
            comment_index_by_platform.each do |platform, (cidx, platform_urls)|
              ids = item_by_issue_id.keys.select { |k| k.start_with?("#{platform}:") }.map { |k| k.split(':', 2).last }
              next if ids.empty?

              page_repos = page_issue_repos[platform].to_a
              next if page_repos.empty?

              resp = cidx
                       .must(terms: { 'tag' => page_repos })
                       .must(terms: { 'issue_id_in_repo' => ids })
                       .must(term: { 'sub_type' => 'issue_comment' }) # 过滤主贴记录（sub_type 为空、body 为空的 issue 正文）
                       .sort(grimoire_creation_date: :asc)
                       .per(1000)
                       .source(%w[issue_id_in_repo user_login body grimoire_creation_date])
                       .execute
                       .raw_response
              (resp&.[]('hits')&.[]('hits') || []).each do |h|
                src = h['_source']
                item = item_by_issue_id["#{platform}:#{src['issue_id_in_repo']}"]
                next unless item

                item[:comments] << {
                  commented_at: src['grimoire_creation_date'],
                  author_login: src['user_login'],
                  author_email: nil,
                  content: src['body']
                }
                logins_by_platform[platform] << src['user_login'] if src['user_login'].present?
              end
            end

            # 邮箱回填：用户索引（*_event_contributor）的 email / commit_email，公开邮箱才有值
            user_index_by_platform = {
              'GiteeIssueEnrich' => GiteeEventContributor,
              'GithubIssueEnrich' => GithubEventContributor,
              'GitcodeIssueEnrich' => GitcodeEventContributor
            }
            email_by_login = {} # "平台:login" => email
            user_index_by_platform.each do |platform, uidx|
              logins = logins_by_platform[platform].to_a
              next if logins.empty?

              resp = begin
                uidx
                  .must(terms: { 'login.keyword' => logins })
                  .per(logins.length)
                  .source(%w[login email commit_email])
                  .execute
                  .raw_response
              rescue SearchFlip::ResponseError => e
                # 该平台无用户索引（如 gitee 无 gitee_event_contributor）时优雅跳过，不影响主流程
                Rails.logger.warn("email backfill skipped (#{platform}): #{e.message[0..100]}")
                nil
              end
              (resp&.[]('hits')&.[]('hits') || []).each do |h|
                src = h['_source']
                email = src['email'].presence || src['commit_email'].presence
                email_by_login["#{platform}:#{src['login']}"] = email if email
              end
            end

            items_with_platform.each do |item, platform|
              item[:author][:email] = email_by_login["#{platform}:#{item[:author][:login]}"]
              item[:assignee][:email] = email_by_login["#{platform}:#{item[:assignee][:login]}"]
              item[:comments].each do |c|
                c[:author_email] = email_by_login["#{platform}:#{c[:author_login]}"]
              end
            end

            { code: 201, data: items, count: total_count, page: params[:page],
              size: params[:size], total_page: (total_count.to_f / params[:size]).ceil }
          end

          # ============ A11 PR 评审数 / 无评审数 / 总数 ============
          desc '某个时间范围项目 pr 评审数、无评审数、总数', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
          end
          post :pr_review_count do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range

            # 按仓库统计：reviewed = num_review_comments > 0，not_reviewed = total - reviewed
            stats = Hash.new { |h, k| h[k] = { total: 0, reviewed: 0 } }
            platform_groups(repo_urls, GiteePullEnrich, GithubPullEnrich, GitcodePullEnrich).each do |idx, urls|
              resp = idx
                       .must(terms: { 'tag' => urls })
                       .range(:grimoire_creation_date, gte: begin_date, lt: end_date)
                       .per(0)
                       .aggregate(
                         by_repo: {
                           terms: { field: 'tag', size: urls.length + 100 },
                           aggs: {
                             reviewed: { filter: { range: { num_review_comments: { gt: 0 } } } }
                           }
                         }
                       )
                       .execute
                       .raw_response
              (resp.dig('aggregations', 'by_repo', 'buckets') || []).each do |b|
                stats[b['key']][:total] += b['doc_count']
                stats[b['key']][:reviewed] += b.dig('reviewed', 'doc_count').to_i
              end
            end

            data = groups.map do |input, repos|
              s = { reviewed: 0, total: 0 }
              repos.each { |r| s[:reviewed] += stats[r][:reviewed]; s[:total] += stats[r][:total] }
              { repo_url: input, pr_reviewed_count: s[:reviewed], pr_not_reviewed_count: s[:total] - s[:reviewed], pr_total_count: s[:total] }
            end

            { code: 201, data: { pr_review_count: data } }
          end

          # ============ A12 PR opened/closed/total/merged ============
          desc '周期内 pr opened/closed/total/merged', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :time_type, type: String, desc: '时间类型 week/month/year', default: 'week'
          end
          post :pr_count_period do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range
            time_type = period_type
            interval = { 'year' => 'year', 'month' => 'month' }[time_type] || 'week'

            # 按仓库聚合：opened 按创建时间、closed 按关闭时间、merged 按合并时间分周期；
            # 查询不设下界（total 需从项目起始累计创建数）
            # histogram 只查 [begin, end)（防大社区全历史周期桶数超限），起始前基线用 filter count 取
            opened_by_repo = Hash.new { |h, k| h[k] = Hash.new(0) }
            closed_by_repo = Hash.new { |h, k| h[k] = Hash.new(0) }
            merged_by_repo = Hash.new { |h, k| h[k] = Hash.new(0) }
            opened_before = Hash.new(0)

            platform_groups(repo_urls, GiteePullEnrich, GithubPullEnrich, GitcodePullEnrich).each do |idx, urls|
              resp = idx
                       .must(terms: { 'tag' => urls })
                       .per(0)
                       .aggregate(
                         by_repo: {
                           terms: { field: 'tag', size: urls.length + 100 },
                           aggs: {
                             opened_before: { filter: { range: { created_at: { lt: begin_date } } } },
                             opened: {
                               filter: { range: { created_at: { gte: begin_date, lt: end_date } } },
                               aggs: { over_time: { date_histogram: { field: :created_at, calendar_interval: interval, min_doc_count: 1 } } }
                             },
                             closed: {
                               filter: { range: { closed_at: { gte: begin_date, lt: end_date } } },
                               aggs: { over_time: { date_histogram: { field: :closed_at, calendar_interval: interval, min_doc_count: 1 } } }
                             },
                             merged: {
                               filter: { range: { merged_at: { gte: begin_date, lt: end_date } } },
                               aggs: { over_time: { date_histogram: { field: :merged_at, calendar_interval: interval, min_doc_count: 1 } } }
                             }
                           }
                         }
                       )
                       .execute
                       .raw_response
              (resp.dig('aggregations', 'by_repo', 'buckets') || []).each do |rb|
                repo = rb['key']
                opened_before[repo] += rb.dig('opened_before', 'doc_count').to_i
                (rb.dig('opened', 'over_time', 'buckets') || []).each do |b|
                  opened_by_repo[repo][period_key(b['key_as_string'], time_type)] += b['doc_count']
                end
                (rb.dig('closed', 'over_time', 'buckets') || []).each do |b|
                  closed_by_repo[repo][period_key(b['key_as_string'], time_type)] += b['doc_count']
                end
                (rb.dig('merged', 'over_time', 'buckets') || []).each do |b|
                  merged_by_repo[repo][period_key(b['key_as_string'], time_type)] += b['doc_count']
                end
              end
            end

            data = groups.map do |input, repos|
              opened = Hash.new(0)
              closed = Hash.new(0)
              merged = Hash.new(0)
              ob = 0
              repos.each do |r|
                (opened_by_repo[r] || {}).each { |d, v| opened[d] += v }
                (closed_by_repo[r] || {}).each { |d, v| closed[d] += v }
                (merged_by_repo[r] || {}).each { |d, v| merged[d] += v }
                ob += opened_before[r]
              end
              pr_period_series(input, opened, closed, merged, begin_date, end_date, time_type, opened_baseline: ob)
            end

            { code: 201, data: { pr_count: data } }
          end

          # ============ A12b PR 创建/关闭/合并数（时间范围汇总） ============
          desc '某个时间范围项目 pr 创建数、关闭数、合并数', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
          end
          post :pr_count do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range

            # 按仓库统计：created 按创建时间、closed 按关闭时间、merged 按合并时间归期
            stats = Hash.new { |h, k| h[k] = { created: 0, closed: 0, merged: 0 } }
            platform_groups(repo_urls, GiteePullEnrich, GithubPullEnrich, GitcodePullEnrich).each do |idx, urls|
              resp = idx
                       .must(terms: { 'tag' => urls })
                       .per(0)
                       .aggregate(
                         by_repo: {
                           terms: { field: 'tag', size: urls.length + 100 },
                           aggs: {
                             created: { filter: { range: { created_at: { gte: begin_date, lt: end_date } } } },
                             closed: { filter: { range: { closed_at: { gte: begin_date, lt: end_date } } } },
                             merged: { filter: { range: { merged_at: { gte: begin_date, lt: end_date } } } }
                           }
                         }
                       )
                       .execute
                       .raw_response
              (resp.dig('aggregations', 'by_repo', 'buckets') || []).each do |b|
                stats[b['key']][:created] += b.dig('created', 'doc_count').to_i
                stats[b['key']][:closed] += b.dig('closed', 'doc_count').to_i
                stats[b['key']][:merged] += b.dig('merged', 'doc_count').to_i
              end
            end

            data = groups.map do |input, repos|
              s = { created: 0, closed: 0, merged: 0 }
              repos.each do |r|
                s[:created] += stats[r][:created]
                s[:closed] += stats[r][:closed]
                s[:merged] += stats[r][:merged]
              end
              { repo_url: input, pr_created_count: s[:created], pr_closed_count: s[:closed], pr_merged_count: s[:merged] }
            end

            { code: 201, data: { pr_count: data } }
          end

          # ============ A13 PR 活动数量（创建/关闭/评论） ============
          desc '某个时间范围项目 pr 活动数量', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
          end
          post :pr_activity_count do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range

            # 按仓库统计：创建活动按 created_at 归期，关闭活动按 closed_at（动作发生时间）归期
            stats = Hash.new { |h, k| h[k] = { created: 0, closed: 0 } }
            platform_groups(repo_urls, GiteePullEnrich, GithubPullEnrich, GitcodePullEnrich).each do |idx, urls|
              resp = idx
                       .must(terms: { 'tag' => urls })
                       .per(0)
                       .aggregate(
                         by_repo: {
                           terms: { field: 'tag', size: urls.length + 100 },
                           aggs: {
                             created: { filter: { range: { created_at: { gte: begin_date, lt: end_date } } } },
                             closed: { filter: { range: { closed_at: { gte: begin_date, lt: end_date } } } }
                           }
                         }
                       )
                       .execute
                       .raw_response
              (resp.dig('aggregations', 'by_repo', 'buckets') || []).each do |b|
                stats[b['key']][:created] += b.dig('created', 'doc_count').to_i
                stats[b['key']][:closed] += b.dig('closed', 'doc_count').to_i
              end
            end

            # 评论活动：2 系列 pulls 索引（gitee2/github2/gitcode2-pulls_enriched）一条评论一条记录，
            # 按 comment_created_at 归期（含机器人模板回复）
            comment_counts = Hash.new(0)
            [
              [Gitee2PullEnrich, repo_urls.select { |u| u.include?('gitee.com') }],
              [Github2PullEnrich, repo_urls.select { |u| u.include?('github.com') }],
              [Gitcode2PullEnrich, repo_urls.select { |u| u.include?('gitcode.com') }]
            ].each do |cidx, urls|
              next if urls.empty?

              resp = cidx
                       .must(terms: { 'tag' => urls })
                       .range(:comment_created_at, gte: begin_date, lt: end_date)
                       .per(0)
                       .aggregate(by_repo: { terms: { field: 'tag', size: urls.length + 100 } })
                       .execute
                       .raw_response
              (resp.dig('aggregations', 'by_repo', 'buckets') || []).each do |b|
                comment_counts[b['key']] += b['doc_count']
              end
            end

            data = groups.map do |input, repos|
              s = { created: 0, closed: 0 }
              repos.each { |r| s[:created] += stats[r][:created]; s[:closed] += stats[r][:closed] }
              { repo_url: input, pr_create_count: s[:created], pr_close_count: s[:closed],
                pr_comment_count: repos.sum { |r| comment_counts[r] } }
            end

            { code: 201, data: { pr_activity_count: data } }
          end

          # ============ A14 PR 元数据 ============
          desc 'PR 元数据', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :page, type: Integer, desc: '页码', default: 1
            optional :size, type: Integer, desc: '每页条数', default: 10
          end
          post :pr_metadata do
            repo_urls = expand_inputs(params[:project_urls])
            begin_date, end_date = time_range

            items = []
            total_count = 0 # 各平台命中总数累加（分页元信息）
            items_with_platform = []
            logins_by_platform = Hash.new { |h, k| h[k] = Set.new }
            # pr id -> item 引用（带平台前缀防跨平台 id 冲突），用于回填评论
            item_by_pr_id = {}

            platform_groups(repo_urls, GiteePullEnrich, GithubPullEnrich, GitcodePullEnrich).each do |idx, urls|
              resp = paged_terms(idx, urls, begin_date, end_date, page: params[:page], size: params[:size])
              total_count += resp&.[]('hits')&.[]('total')&.[]('value').to_i
              hits = resp&.[]('hits')&.[]('hits') || []
              hits.each do |data|
                s = data['_source']
                item = {
                  repo_url: s['tag'],
                  url: s['url'] || s['issue_url'],
                  title: s['title'],
                  created_at: s['created_at'],
                  author: { login: s['user_login'], name: s['author_name'], email: nil, domain: s['author_domain'], organization: s['author_org_name'] },
                  closed_at: s['closed_at'],
                  merged: s['merged'],
                  merged_at: s['merged_at'],
                  merge_author: { login: s['merge_author_login'], name: s['merge_author_name'], email: nil, organization: s['merge_author_org'] },
                  num_review_comments: s['num_review_comments'],
                  comments: []
                }
                items << item
                items_with_platform << [item, idx.name]
                logins_by_platform[idx.name] << s['user_login'] if s['user_login'].present?
                logins_by_platform[idx.name] << s['merge_author_login'] if s['merge_author_login'].present?
                item_by_pr_id["#{idx.name}:#{s['id_in_repo']}"] = item if s['id_in_repo'].present?
              end
            end

            # 邮箱回填：用户索引（*_event_contributor）的 email / commit_email，公开邮箱才有值
            user_index_by_platform = {
              'GiteePullEnrich' => GiteeEventContributor,
              'GithubPullEnrich' => GithubEventContributor,
              'GitcodePullEnrich' => GitcodeEventContributor
            }
            email_by_login = {} # "平台:login" => email
            user_index_by_platform.each do |platform, uidx|
              logins = logins_by_platform[platform].to_a
              next if logins.empty?

              resp = begin
                uidx
                  .must(terms: { 'login.keyword' => logins })
                  .per(logins.length)
                  .source(%w[login email commit_email])
                  .execute
                  .raw_response
              rescue SearchFlip::ResponseError => e
                # 该平台无用户索引（如 gitee 无 gitee_event_contributor）时优雅跳过，不影响主流程
                Rails.logger.warn("email backfill skipped (#{platform}): #{e.message[0..100]}")
                nil
              end
              (resp&.[]('hits')&.[]('hits') || []).each do |h|
                src = h['_source']
                email = src['email'].presence || src['commit_email'].presence
                email_by_login["#{platform}:#{src['login']}"] = email if email
              end
            end

            items_with_platform.each do |item, platform|
              item[:author][:email] = email_by_login["#{platform}:#{item[:author][:login]}"]
              item[:merge_author][:email] = email_by_login["#{platform}:#{item[:merge_author][:login]}"]
            end

            # 评论回填：2 系列 pulls 索引（gitee2/github2/gitcode2-pulls_enriched）一条评论一条记录
            comment_index_by_platform = {
              'GiteePullEnrich' => [Gitee2PullEnrich, repo_urls.select { |u| u.include?('gitee.com') }],
              'GithubPullEnrich' => [Github2PullEnrich, repo_urls.select { |u| u.include?('github.com') }],
              'GitcodePullEnrich' => [Gitcode2PullEnrich, repo_urls.select { |u| u.include?('gitcode.com') }]
            }
            # 当前页涉及的仓库（而非全部入参仓库），避免大 term 数组导致超时
            page_repos_by_platform = Hash.new { |h, k| h[k] = Set.new }
            items_with_platform.each do |item, platform|
              page_repos_by_platform[platform] << item[:repo_url] if item[:repo_url]
            end
            comment_index_by_platform.each do |platform, (cidx, platform_urls)|
              ids = item_by_pr_id.keys.select { |k| k.start_with?("#{platform}:") }.map { |k| k.split(':', 2).last }
              next if ids.empty?

              # 只查当前页 PR 所在仓库（收窄 tag），避免 700+ 仓库的全量 term 过滤超时
              page_repos = page_repos_by_platform[platform].to_a
              next if page_repos.empty?

              resp = cidx
                       .must(terms: { 'tag' => page_repos })
                       .must(terms: { 'pull_id_in_repo' => ids })
                       .sort(comment_created_at: :asc)
                       .per(1000)
                       .source(%w[pull_id_in_repo user_login body comment_created_at])
                       .execute
                       .raw_response
              (resp&.[]('hits')&.[]('hits') || []).each do |h|
                src = h['_source']
                item = item_by_pr_id["#{platform}:#{src['pull_id_in_repo']}"]
                next unless item

                item[:comments] << {
                  commented_at: src['comment_created_at'],
                  author_login: src['user_login'],
                  author_email: nil,
                  content: src['body']
                }
                logins_by_platform[platform] << src['user_login'] if src['user_login'].present?
              end
            end

            # 评论人邮箱回填（二次查用户索引，第一次可能漏了评论人）
            user_index_by_platform = {
              'GiteePullEnrich' => GiteeEventContributor,
              'GithubPullEnrich' => GithubEventContributor,
              'GitcodePullEnrich' => GitcodeEventContributor
            }
            comment_email_by_login = {} # "平台:login" => email
            user_index_by_platform.each do |platform, uidx|
              logins = logins_by_platform[platform].to_a
              next if logins.empty?

              resp = begin
                uidx
                  .must(terms: { 'login.keyword' => logins })
                  .per(logins.length)
                  .source(%w[login email commit_email])
                  .execute
                  .raw_response
              rescue SearchFlip::ResponseError => e
                # 该平台无用户索引（如 gitee 无 gitee_event_contributor）时优雅跳过，不影响主流程
                Rails.logger.warn("email backfill skipped (#{platform}): #{e.message[0..100]}")
                nil
              end
              (resp&.[]('hits')&.[]('hits') || []).each do |h|
                src = h['_source']
                email = src['email'].presence || src['commit_email'].presence
                comment_email_by_login["#{platform}:#{src['login']}"] = email if email
              end
            end

            items_with_platform.each do |item, platform|
              item[:comments].each do |c|
                c[:author_email] = comment_email_by_login["#{platform}:#{c[:author_login]}"]
              end
            end

            { code: 201, data: items, count: total_count, page: params[:page],
              size: params[:size], total_page: (total_count.to_f / params[:size]).ceil }
          end

          # ============ A15 华为/非华为 贡献者数 ============
          desc '多个项目华为/非华为贡献者数', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
          end
          post :contributor_company_count do
            groups = expand_inputs_grouped(params[:project_urls])
            begin_date, end_date = time_range

            # 每组（仓库/社区）独立计算：组级批量查询（每平台一次），避免逐仓库循环。
            data = groups.map do |input, repos|
              acc = { huawei: Set.new, non_huawei: Set.new, d0: Set.new, d1: Set.new, d2: Set.new }
              truncated = false
              platform_groups(repos, GiteeContributorEnrich, GithubContributorEnrich, GitcodeContributorEnrich).each do |idx, urls|
                r = idx.contributor_company_and_tiers(urls, begin_date, end_date)
                acc[:huawei].merge(r[:huawei])
                acc[:non_huawei].merge(r[:non_huawei])
                acc[:d0].merge(r[:d0])
                acc[:d1].merge(r[:d1])
                acc[:d2].merge(r[:d2])
                truncated ||= r[:truncated]
              end

              result = { repo_url: input,
                         huawei_contributor_count: acc[:huawei].size,
                         non_huawei_contributor_count: acc[:non_huawei].size,
                         contributor_total_count: acc[:d0].size,
                         d0_contributor_count: acc[:d0].size,
                         d1_contributor_count: acc[:d1].size,
                         d2_contributor_count: acc[:d2].size }
              result[:truncated] = true if truncated
              result
            end

            { code: 201, data: { contributor_company_count: data } }
          end

          # ============ A16 周期内贡献者数量 + 总数 ============
          desc '周期内贡献者数量 + 贡献者总数', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :time_type, type: String, desc: '时间类型 week/month/year', default: 'week'
          end
          post :contributor_count_period do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range
            time_type = period_type

            # 取每位贡献者的首次出现时间（贡献者索引，全历史，不设下界）。
            # 单层 by_user 聚合（不再按仓库嵌套，避免 仓库数×3万 桶数超 ES 上限）；
            # 按组查询，组内跨仓库天然按 contributor.keyword 去重，取最早首次出现时间
            # 每位贡献者记录：首次出现时间 + 是否华为（取最新 organization 判定）
            first_seen_by_group = {}
            groups.each_with_index do |(input, repos), gi|
              seen = {} # user => { first:, huawei: }
              platform_groups(repos, GiteeContributorEnrich, GithubContributorEnrich, GitcodeContributorEnrich).each do |idx, urls|
                resp = idx
                         .must(terms: { 'repo_name.keyword' => urls })
                         .must(range: { contribution: { gt: 0 } })
                         .per(0)
                         .aggregate(
                           by_user: {
                             terms: { field: 'contributor.keyword', size: 30_000 },
                             aggs: {
                               first: { min: { field: 'grimoire_creation_date' } },
                               latest: {
                                 top_hits: {
                                   size: 1,
                                   sort: [{ grimoire_creation_date: { order: 'desc' } }],
                                   _source: { includes: ['organization'] }
                                 }
                               }
                             }
                           }
                         )
                         .execute
                         .raw_response
                (resp.dig('aggregations', 'by_user', 'buckets') || []).each do |ub|
                  ms = ub.dig('first', 'value').to_i
                  next if ms <= 0

                  org = ub.dig('latest', 'hits', 'hits', 0, '_source', 'organization')
                  t = Time.at(ms / 1000.0)
                  cur = seen[ub['key']]
                  if cur.nil?
                    seen[ub['key']] = { first: t, huawei: huawei?(org) }
                  elsif t < cur[:first]
                    cur[:first] = t
                    cur[:huawei] = huawei?(org)
                  end
                end
              end
              first_seen_by_group[gi] = seen
            end

            data = groups.each_with_index.map do |(input, repos), gi|
              seen = first_seen_by_group[gi] || {}

              # 按周期归集首次出现（从项目初期到 end，与 start_time 无关地累计），并拆分华为/非华为
              new_by_period = Hash.new(0)
              new_huawei = Hash.new(0)
              new_non_huawei = Hash.new(0)
              baseline = 0 # 起始周期之前的累计贡献者（total 的起点）
              seen.each_value do |e|
                t = e[:first]
                next if t >= end_date

                if t < begin_date
                  baseline += 1
                else
                  key = period_key(t.iso8601, time_type)
                  new_by_period[key] += 1
                  e[:huawei] ? new_huawei[key] += 1 : new_non_huawei[key] += 1
                end
              end

              # 输出周期：从 begin_date 所在周期起补齐到 end 前一天所在周期
              items = []
              if seen.values.any? { |e| e[:first] < end_date }
                first = period_key(begin_date.to_s, time_type) # 起始周期（含 baseline 计入期）
                cursor = Date.parse(first)
                last_period = Date.parse(period_key((end_date - 1.day).to_s, time_type))
                running = baseline
                loop do
                  key = cursor.to_s
                  new_count = new_by_period[key] || 0
                  running += new_count
                  items << { date: key, new_count: new_count, total_count: running,
                             new_huawei_contributor_count: new_huawei[key] || 0,
                             new_non_huawei_contributor_count: new_non_huawei[key] || 0 }
                  break if cursor >= last_period

                  cursor = next_period_end(cursor, time_type)
                end
              end

              { repo_url: input, items: items }
            end

            { code: 201, data: { contributor_count_period: data } }
          end

          # ============ A17 代码新增/删除量 + 华为/非华为提交次数（周期） ============
          desc '周期内代码新增/删除量 + 华为/非华为贡献者提交次数', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :time_type, type: String, desc: '时间类型 week/month/year', default: 'week'
            optional :branch, type: String, desc: '分支', default: 'master'
          end
          post :commit_lines_count do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range
            time_type = period_type
            branch = params[:branch] || 'master'

            # 一次聚合拿到各仓库每周期：commit 数 / 新增行 / 删除行 / 华为 commit 数
            series_by_repo = {}
            platform_groups(repo_urls, GiteeGitEnrich, GithubGitEnrich, GitcodeGitEnrich).each do |idx, urls|
              commit_count_period_data(idx, urls, begin_date, end_date, time_type, branch).each do |repo, series|
                series_by_repo[repo] = series
              end
            end

            data = groups.map do |input, repos|
              lines_added = Hash.new(0)
              lines_removed = Hash.new(0)
              huawei = Hash.new(0)
              commits = Hash.new(0)
              repos.each do |r|
                (series_by_repo[r] || []).each do |item|
                  lines_added[item[:date]] += item[:lines_added]
                  lines_removed[item[:date]] += item[:lines_removed]
                  huawei[item[:date]] += item[:huawei_commits]
                  commits[item[:date]] += item[:commits]
                end
              end
              non_huawei = commits.each_with_object({}) { |(d, c), h| h[d] = c - huawei[d] }
              { repo_url: input,
                lines_added: lines_added, lines_removed: lines_removed,
                huawei_commit_count: huawei, non_huawei_commit_count: non_huawei }
            end

            { code: 201, data: { commit_lines_count: data } }
          end

          # ============ A18 华为/非华为贡献者提交次数 ============
          desc '华为/非华为贡献者提交次数', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :branch, type: String, desc: '分支', default: 'master'
          end
          post :commit_company_count do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range
            branch = params[:branch] || 'master'

            stats = Hash.new { |h, k| h[k] = { huawei: 0, total: 0 } }
            platform_groups(repo_urls, GiteeGitEnrich, GithubGitEnrich, GitcodeGitEnrich).each do |idx, urls|
              commit_counts_by_repo(idx, urls, begin_date, end_date, branch).each do |repo, c|
                stats[repo][:huawei] += c[:huawei]
                stats[repo][:total] += c[:total]
              end
            end

            data = groups.map do |input, repos|
              s = { huawei: 0, total: 0 }
              repos.each { |r| s[:huawei] += stats[r][:huawei]; s[:total] += stats[r][:total] }
              { repo_url: input, huawei_commit_count: s[:huawei], non_huawei_commit_count: s[:total] - s[:huawei] }
            end

            { code: 201, data: { commit_company_count: data } }
          end

          # ============ A19 华为/非华为组织代码变更量 ============
          desc '华为/非华为组织代码变更量', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :branch, type: String, desc: '分支', default: 'master'
          end
          post :commit_company_lines_count do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range
            branch = params[:branch] || 'master'

            # 一次聚合：按 tag（仓库）分桶，桶内统计总新增/删除行，以及华为组织的新增/删除行
            stats = Hash.new do |h, k|
              h[k] = { huawei_added: 0.0, huawei_removed: 0.0, total_added: 0.0, total_removed: 0.0 }
            end
            hw_domains = huawei_domains

            platform_groups(repo_urls, GiteeGitEnrich, GithubGitEnrich, GitcodeGitEnrich).each do |idx, urls|
              git_urls = urls.map { |u| u.sub(/\.git\z/, '') + '.git' }
              base = idx
                       .must(terms: { 'tag' => git_urls })
                       .must(wildcard: { author_email: { value: '*@*' } })
                       .must(wildcard: { committer_email: { value: '*@*' } })
                       .must(range: { lines_changed: { gt: 0 } })
                       .must_not(terms: { author_email: ['mamingshuai@huawei.com', 'wenjun1@huawei.com'] })
                       .must_not(terms: { committer_email: ['mamingshuai@huawei.com', 'wenjun1@huawei.com'] })
                       .must_not(wildcard: { author_email: { value: '*noreply*' } })
                       .must_not(wildcard: { committer_email: { value: '*noreply*' } })
                       .must_not(wildcard: { message: { value: '*Merge pull request*' } })
                       .range(:grimoire_creation_date, gte: begin_date, lt: end_date)
              base = base.must(match_phrase: { branches: "'#{branch}'" }) if branch.present?

              resp = base
                       .per(0)
                       .aggregate(
                         by_repo: {
                           terms: { field: 'tag', size: git_urls.length + 100 },
                           aggs: {
                             lines_added: { sum: { field: 'lines_added' } },
                             lines_removed: { sum: { field: 'lines_removed' } },
                             huawei: {
                               filter: { terms: { author_domain: hw_domains } },
                               aggs: {
                                 lines_added: { sum: { field: 'lines_added' } },
                                 lines_removed: { sum: { field: 'lines_removed' } }
                               }
                             }
                           }
                         }
                       )
                       .execute
                       .raw_response
              (resp&.[]('aggregations')&.[]('by_repo')&.[]('buckets') || []).each do |b|
                repo = b['key'].to_s.sub(/\.git\z/, '')
                stats[repo][:total_added] += b.dig('lines_added', 'value').to_f
                stats[repo][:total_removed] += b.dig('lines_removed', 'value').to_f
                stats[repo][:huawei_added] += b.dig('huawei', 'lines_added', 'value').to_f
                stats[repo][:huawei_removed] += b.dig('huawei', 'lines_removed', 'value').to_f
              end
            end

            data = repo_urls.map do |u|
              s = stats[u]
              { repo_url: u,
                huawei_lines_added: s[:huawei_added].to_i,
                huawei_lines_removed: s[:huawei_removed].to_i,
                huawei_lines_changed: (s[:huawei_added] + s[:huawei_removed]).to_i,
                non_huawei_lines_added: (s[:total_added] - s[:huawei_added]).to_i,
                non_huawei_lines_removed: (s[:total_removed] - s[:huawei_removed]).to_i,
                non_huawei_lines_changed: (s[:total_added] + s[:total_removed] - s[:huawei_added] - s[:huawei_removed]).to_i }
            end

            { code: 201, data: { commit_company_lines_count: data } }
          end

          # ============ A20 commit 提交（创建）数量 ============
          desc '某个时间范围 commit 提交（创建）数量', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :branch, type: String, desc: '分支', default: 'master'
          end
          post :commit_count do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range
            branch = params[:branch] || 'master'

            counts = Hash.new(0)
            platform_groups(repo_urls, GiteeGitEnrich, GithubGitEnrich, GitcodeGitEnrich).each do |idx, urls|
              commit_counts_by_repo(idx, urls, begin_date, end_date, branch).each { |repo, c| counts[repo] += c[:total] }
            end

            data = groups.map { |input, repos| { repo_url: input, commit_count: repos.sum { |r| counts[r] } } }

            { code: 201, data: { commit_count: data } }
          end

          # ============ A21 commit 活动数量（创建，评论暂无） ============
          desc '某个时间范围 commit 活动数量', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :branch, type: String, desc: '分支', default: 'master'
          end
          post :commit_activity_count do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range
            branch = params[:branch] || 'master'

            counts = Hash.new(0)
            platform_groups(repo_urls, GiteeGitEnrich, GithubGitEnrich, GitcodeGitEnrich).each do |idx, urls|
              commit_counts_by_repo(idx, urls, begin_date, end_date, branch).each { |repo, c| counts[repo] += c[:total] }
            end

            data = groups.map { |input, repos| { repo_url: input, commit_create_count: repos.sum { |r| counts[r] }, commit_comment_count: nil } }

            { code: 201, data: { commit_activity_count: data } }
          end

          # ============ A22 周期内 commit 数 + 总数 ============
          desc '周期内 commit 数 + commit 总数', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :time_type, type: String, desc: '时间类型 week/month/year', default: 'week'
            optional :branch, type: String, desc: '分支', default: 'master'
          end
          post :commit_count_period do
            groups = expand_inputs_grouped(params[:project_urls])
            repo_urls = groups.sum([], &:last)
            begin_date, end_date = time_range
            time_type = period_type
            branch = params[:branch] || 'master'

            counts_by_repo = Hash.new { |h, k| h[k] = Hash.new(0) }
            added_by_repo = Hash.new { |h, k| h[k] = Hash.new(0) }
            removed_by_repo = Hash.new { |h, k| h[k] = Hash.new(0) }
            baseline_by_repo = Hash.new(0) # 项目初期到 begin_date 之前的累计 commit 数

            platform_groups(repo_urls, GiteeGitEnrich, GithubGitEnrich, GitcodeGitEnrich).each do |idx, urls|
              commit_count_period_data(idx, urls, begin_date, end_date, time_type, branch).each do |repo, series|
                series.each do |item|
                  counts_by_repo[repo][item[:date]] += item[:commits]
                  added_by_repo[repo][item[:date]] += item[:lines_added]
                  removed_by_repo[repo][item[:date]] += item[:lines_removed]
                end
              end
              # 基线：项目初期 ~ begin_date 的累计 commit（与 start_time 无关的累计起点）
              commit_counts_by_repo(idx, urls, Time.parse('1970-01-01'), begin_date, branch)
                .each { |repo, c| baseline_by_repo[repo] += c[:total] }
            end

            data = groups.map do |input, repos|
              counts = Hash.new(0)
              added = Hash.new(0)
              removed = Hash.new(0)
              baseline = 0
              repos.each do |r|
                (counts_by_repo[r] || {}).each { |d, v| counts[d] += v }
                (added_by_repo[r] || {}).each { |d, v| added[d] += v }
                (removed_by_repo[r] || {}).each { |d, v| removed[d] += v }
                baseline += baseline_by_repo[r]
              end
              # 逐周期：new = 当期 commit 数，total = 项目初期累计到该周期末
              running = baseline
              items = counts.keys.sort_by { |d| Time.parse(d) }.map do |d|
                new_count = counts[d]
                running += new_count
                { date: d, new_count: new_count, total_count: running,
                  lines_added: added[d], lines_removed: removed[d] }
              end
              { repo_url: input, items: items }
            end

            { code: 201, data: { commit_count_period: data } }
          end

          # ============ A23 Commit 元数据 ============
          desc 'Commit 元数据', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
            optional :page, type: Integer, desc: '页码', default: 1
            optional :size, type: Integer, desc: '每页条数', default: 10
            optional :branch, type: String, desc: '分支', default: 'master'
          end
          post :commit_metadata do
            repo_urls = expand_inputs(params[:project_urls])
            begin_date, end_date = time_range
            branch = params[:branch] || 'master'

            items = []
            total_count = 0 # 各平台命中总数累加（分页元信息）
            platform_groups(repo_urls, GiteeGitEnrich, GithubGitEnrich, GitcodeGitEnrich).each do |idx, urls|
              resp = idx.fetch_commit_page_by_repo_urls(urls, begin_date, end_date, branch, per: params[:size], page: params[:page])
              # 精确总数：复用 commit 过滤条件，track_total_hits(true) 解除 ES 1 万条上限
              cnt_resp = idx.base_commit_list_by_repo_urls(urls, begin_date, end_date, branch)
                            .per(0).track_total_hits(true).execute.raw_response
              total_count += cnt_resp&.[]('hits')&.[]('total')&.[]('value').to_i
              hits = resp&.[]('hits')&.[]('hits') || []
              hits.each do |data|
                s = data['_source']
                items << {
                  repo_url: s['tag'].to_s.sub(/\.git\z/, ''),
                  hash: s['hash'],
                  message: s['message'],
                  committed_at: s['grimoire_creation_date'],
                  author: { name: s['author_name'], email: s['author_email'], domain: s['author_domain'], organization: s['author_org_name'] },
                  committer: { name: s['committer_name'], email: s['committer_email'], domain: s['committer_domain'] },
                  lines_added: s['lines_added'],
                  lines_removed: s['lines_removed']
                }
              end
            end

            { code: 201, data: items, count: total_count, page: params[:page],
              size: params[:size], total_page: (total_count.to_f / params[:size]).ceil }
          end

          # ============ A24 OssCompass 指数 ============
          desc '社区/代码仓活跃度、社区服务与支撑、协作开发、组织活跃度', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
          end
          post :oss_compass_index do
            groups = expand_inputs_grouped(params[:project_urls])
            begin_date, end_date = time_range

            data = groups.map do |input, repos|
              # 社区输入：直接取平台计算的社区级指标（按社区名 label）；
              # 仓库输入：按仓库 label 查询
              expanded = repos != [input.chomp('/')]
              # 社区：URL 入参取 star_projects 登记的社区名，名字入参本身就是社区 label
              labels = expanded ? [get_community_name(input) || input].compact : repos
              labels = repos if labels.empty?

              activities = get_index_last_data_agg(ActivityMetric, labels, ['label', 'activity_score'], begin_date, end_date)
              community = get_index_last_data_agg(CommunityMetric, labels, ['label', 'community_support_score'], begin_date, end_date)
              codequality = get_index_last_data_agg(CodequalityMetric, labels, ['label', 'code_quality_guarantee'], begin_date, end_date)
              group = get_index_last_data_agg(GroupActivityMetric, labels, ['label', 'organizations_activity'], begin_date, end_date)

              raw = {}
              [activities, community, codequality, group].each do |items|
                items.first&.each do |k, v|
                  raw[k.to_sym] = v unless k.to_s == 'label'
                end
              end
              { repo_url: input }
                .merge(index_score_fields(raw[:activity_score], raw[:community_support_score],
                                          raw[:code_quality_guarantee], raw[:organizations_activity]))
            end

            { code: 201, data: data }
          end

          # ============ A24b OssCompass 指数周期序列 ============
          desc 'OssCompass 指数周期序列（活跃度/社区服务支撑/协作开发/组织活跃度，按项目）', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :project_urls, type: Array[String], desc: '项目地址'
            optional :start_time, type: DateTime, desc: '开始时间'
            optional :end_time, type: DateTime, desc: '结束时间'
          end
          post :oss_compass_index_period do
            groups = expand_inputs_grouped(params[:project_urls])
            begin_date, end_date = time_range

            data = groups.map do |input, repos|
              # 社区输入：取社区级指标 label；仓库输入：取仓库 label
              expanded = repos != [input.chomp('/')]
              # 社区：URL 入参取 star_projects 登记的社区名，名字入参本身就是社区 label
              labels = expanded ? [get_community_name(input) || input].compact : repos
              labels = repos if labels.empty?

              label = labels.first
              activity = metric_snapshot_series(ActivityMetric, [label], 'activity_score', begin_date, end_date)[label] || {}
              community = metric_snapshot_series(CommunityMetric, [label], 'community_support_score', begin_date, end_date)[label] || {}
              codequality = metric_snapshot_series(CodequalityMetric, [label], 'code_quality_guarantee', begin_date, end_date)[label] || {}
              group_activity = metric_snapshot_series(GroupActivityMetric, [label], 'organizations_activity', begin_date, end_date)[label] || {}

              dates = (activity.keys | community.keys | codequality.keys | group_activity.keys).sort_by { |d| Time.parse(d) }
              items = dates.map do |d|
                { date: d }.merge(index_score_fields(activity[d], community[d], codequality[d], group_activity[d]))
              end
              { repo_url: input, items: items }
            end

            { code: 201, data: { oss_compass_index_period: data } }
          end

          # ============ A25 用户头像 ============
          desc '获取平台用户头像', hidden: true, tags: ['starProjectV2'], success: { code: 201 }
          params do
            requires :login, type: String, desc: '用户登录名'
            optional :platform, type: String, desc: '平台 github/gitee/gitcode', default: 'github'
          end
          post :user_avatar do
            login = params[:login]
            platform = (params[:platform] || 'github').to_s.downcase

            avatar_url = case platform
                         when 'gitee' then GiteeEventContributor.query_name(login)['avatar_url']
                         when 'gitcode' then GitcodeEventContributor.query_name(login)['avatar_url']
                         else GithubEventContributor.query_name(login)['avatar_url']
                         end

            { code: 201, data: { login: login, platform: platform, avatar_url: avatar_url } }
          end
        end
      end
    end
  end
end
