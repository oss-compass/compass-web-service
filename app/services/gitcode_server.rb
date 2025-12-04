
require 'json'

class GitcodeServer

  include Common
  BASE_URL = ENV.fetch("GITCODE_BASE_URL")
  TOKEN = ENV.fetch("GITCODE_API_TOKEN")

  def initialize
    @conn = Faraday.new(url: BASE_URL) do |f|
      f.headers['Content-Type'] = 'application/json'
      f.headers['Accept'] = 'application/json'
      f.headers['Authorization'] = TOKEN
      # 设置超时时间（可选）
      f.options.timeout = 30
      f.options.open_timeout = 10
      f.adapter Faraday.default_adapter
    end
  end

  # 创建仓库
  def create_repo(repo_info)
    owner = repo_info[:owner]
    is_org = repo_info[:is_org] || false

    #  API 路径
    endpoint = is_org ? "/api/v5/orgs/#{owner}/repos" : "/api/v5/user/repos"

    payload = {
      name: repo_info[:name],
      description: repo_info[:description] || '',
      homepage: repo_info[:homepage] || '',
      private: repo_info.fetch(:private, false),
      auto_init: repo_info.fetch(:auto_init, true),
      default_branch: repo_info.fetch(:default_branch, 'main')
    }

    payload[:import_url] = repo_info[:import_url] if repo_info[:import_url].present?
    payload[:license_template] = repo_info[:license_template] if repo_info[:license_template].present?

    response = @conn.post(endpoint) do |req|
      req.body = payload.to_json
    end

    handle_response(response, "创建仓库 [#{repo_info[:name]}]")
  end

  # 添加协作者
  def add_collaborator(owner, repo, username, permission)
    endpoint = "/api/v5/repos/#{owner}/#{repo}/collaborators/#{username}"
    payload = { permission: permission }

    response = @conn.put(endpoint) do |req|
      req.body = payload.to_json
    end

    success = [200, 201, 204].include?(response.status)
    log_result(success, "添加协作者 [#{username}] 到 #{owner}/#{repo}", response.body)
    success
  end


  # 1 (继承模式) -> 改为 2 (独立模式)
  def update_repo_model(owner, repo)
    endpoint = "/api/v5/repos/#{owner}/#{repo}/transition"

    # 1. 获取当前模式
    response = @conn.get(endpoint)

    if [200, 201, 204].include?(response.status)
      begin
        data = JSON.parse(response.body)
        # 默认认为是 2 (独立模式)，防止字段缺失
        current_mode = data['memberMgntMode'] || 2

        mode_name = (current_mode == 1 ? '继承模式' : '独立模式')
        Rails.logger.info "[GitCode] 获取权限模式: #{current_mode} (#{mode_name})"

        # 2. 如果是继承模式(1)，则修改为独立模式(2)
        if current_mode == 1
          payload = { mode: 2 }

          put_response = @conn.put(endpoint) do |req|
            req.body = payload.to_json
          end

          # 复用 handle_response 处理结果 (会自动记录日志或抛出异常)
          handle_response(put_response, "将权限模式从继承改为独立")
        else
          Rails.logger.info "[GitCode] ✓ 当前已是独立模式，无需修改"
          true
        end
      rescue JSON::ParserError
        error_msg = "解析权限模式响应失败: #{response.body}"
        Rails.logger.error "[GitCode] ✗ #{error_msg}"
        raise error_msg
      end
    else
      # 获取失败，抛出异常
      body_str = response.body.to_s.force_encoding('UTF-8')
      body_str = body_str.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?') unless body_str.valid_encoding?

      error_msg = "获取权限模式失败 (Status: #{response.status}): #{body_str}"
      Rails.logger.error "[GitCode] ✗ #{error_msg}"
      raise error_msg
    end
  end


  #  创建标签
  def create_tag(owner, repo, tag_info)
    endpoint = "/api/v5/repos/#{owner}/#{repo}/tags"
    payload = {
      refs: tag_info[:refs] || 'main',
      tag_name: tag_info[:tag_name],
      tag_message: tag_info[:tag_message] || ''
    }

    response = @conn.post(endpoint) do |req|
      req.body = payload.to_json
    end

    success = [200, 201].include?(response.status)
    log_result(success, "创建标签 [#{tag_info[:tag_name]}]", response.body)
    success
  end


    # 新增: 创建项目标签 (Label)
  def create_label(owner, repo, label_name)
    endpoint = "/api/v5/repos/#{owner}/#{repo}/project_labels"
    # 对应 Python: payload = json.dumps([label_name])
    # 注意：GitCode 这个接口要求 payload 是一个字符串数组
    payload = [label_name]

    response = @conn.put(endpoint) do |req|
      req.body = payload.to_json
    end

    handle_response(response, "创建项目标签 [#{label_name}]")
  end


  private

  def handle_response(response, action_name)
    if [200, 201].include?(response.status)
      Rails.logger.info "[GitCode] ✓ #{action_name} 成功"
      true
    else
      Rails.logger.error "[GitCode] ✗ #{action_name} 失败 (Status: #{response.status}): #{response.body}"
      # 返回错误信息 error_message
      body_json = JSON.parse(response.body)
      detailed_error = body_json['error_message']
      return  detailed_error
    end
  end

  def log_result(success, action_name, error_body = nil)
    if success
      Rails.logger.info "[GitCode] ✓ #{action_name} 成功"
    else
      Rails.logger.error "[GitCode] ✗ #{action_name} 失败: #{error_body}"
    end
  end
end
