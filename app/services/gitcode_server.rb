
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
  def add_collaborator(owner, repo, username, permission = 'push')
    # 注意：根据你的Python脚本，这里的path结构是 /repos/:owner/:repo/collaborators/:username
    endpoint = "/api/v5/repos/#{owner}/#{repo}/collaborators/#{username}"
    payload = { permission: permission }

    response = @conn.put(endpoint) do |req|
      req.body = payload.to_json
    end

    success = [200, 201, 204].include?(response.status)
    log_result(success, "添加协作者 [#{username}] 到 #{owner}/#{repo}", response.body)
    success
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
