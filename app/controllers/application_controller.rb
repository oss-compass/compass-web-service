class ApplicationController < ActionController::Base

  skip_before_action :verify_authenticity_token

  include Pagy::Backend
  include Common
  include GiteeApplication
  include GithubApplication

  before_action :auth_validate, only: [:workflow, :hook]

  after_action { pagy_headers_merge(@pagy) if @pagy }

  def workflow
    payload = request.request_parameters

    action = payload['action']
    action_desc = payload['action_desc']
    @pr_number = payload['iid'] || payload['number']
    @merged_at = payload['pull_request']&.[]('merged_at')
    result =
      case action
      when 'open', 'reopen', 'opened', 'synchronize'
        check_yaml(payload)
      when 'update'
        if action_desc == 'source_branch_changed'
          check_yaml(payload)
        end
      when 'merge'
        submit_task(payload)
      when 'closed'
        if @merged_at.present?
          submit_task(payload)
        end
      end

    if result.present? && result.is_a?(Hash)
      notify_on_pr(@pr_number, quote_mark(YAML.dump(result)))
    end

    render json: result
  end

  def hook
    payload = request.request_parameters
    result = payload['result'].to_h
    domain = payload['domain']
    pr_number = payload['pr_number']

    if result.present? && result.is_a?(Hash)
      notify_on_pr(pr_number, quote_mark(YAML.dump(result)), domain: domain)
    end

    { status: true, message: 'ok' }
  end

  def website
    render template: 'layouts/website'
  end

  def panel
    return redirect_to website_path unless user_signed_in?

    render template: 'layouts/panel'
  end

  protected

  def check_yaml(payload)
    diff_url = payload&.[]('pull_request')&.[]('diff_url')
    @branch = payload&.[]('pull_request')&.[]('head')&.[]('ref')
    if diff_url.present?
      result = []
      RestClient.proxy = PROXY unless extract_domain(diff_url).start_with?('gitee')
      diff = RestClient.get(diff_url).body
      patches = GitDiffParser.parse(diff)
      patches.each do |patch|
        if patch.file.start_with?(SINGLE_DIR)
          result << analyze_yaml_file(patch.file)
        elsif patch.file.start_with?(ORG_DIR)
          result << analyze_org_yaml_file(patch.file)
        else
          result << { status: false, message: "invaild configure yaml path: #{patch.file}" }
        end
      end
      { status: true, message: 'ok', result: result }
    else
      { status: false, message: 'invalid diff url' }
    end
  rescue => ex
    { status: false, message: ex.message }
  end

  def submit_task(payload)
    diff_url = payload&.[]('pull_request')&.[]('diff_url')
    @branch = payload&.[]('pull_request')&.[]('base')&.[]('ref')
    if diff_url.present?
      result = []
      RestClient.proxy = PROXY unless extract_domain(diff_url).start_with?('gitee')
      diff = RestClient.get(diff_url).body
      patches = GitDiffParser.parse(diff)
      patches.each do |patch|
        if patch.file.start_with?(SINGLE_DIR)
          result << analyze_yaml_file(patch.file, only_validate: false)
        elsif patch.file.start_with?(ORG_DIR)
          result << analyze_org_yaml_file(patch.file, only_validate: false)
        else
          result << { status: false, message: "invaild configure yaml path: #{patch.file}" }
        end
      end
      { status: true, message: 'ok', result: result }
    else
      { status: false, message: 'invalid diff url' }
    end
  rescue => ex
    { status: false, message: ex.message }
  end

  def analyze_yaml_file(path, only_validate: true)
    yaml_url = generate_yml_url(path)
    RestClient.proxy = PROXY unless extract_domain(yaml_url).start_with?('gitee')
    yaml = YAML.load(RestClient.get(yaml_url).body)
    AnalyzeServer.new(
      {
        repo_url: yaml['data_sources']['repo_name'],
        raw: true,
        enrich: true,
        activity: true,
        community: true,
        codequality: true,
        callback: {
          hook_url: "#{HOST}/api/hook",
          params: { pr_number: @pr_number }
        }
      }
    ).execute(only_validate: only_validate).merge(path: path)
  rescue => ex
    { status: false, path: path, message: ex.message }
  end

  def analyze_org_yaml_file(path, only_validate: true)
    yaml_url = generate_yml_url(path)
    AnalyzeGroupServer.new(
      {
        yaml_url: yaml_url,
        raw: true,
        enrich: true,
        activity: true,
        community: true,
        codequality: true,
        callback: {
          hook_url: "#{HOST}/api/hook",
          params: { pr_number: @pr_number }
        }
      }
    ).execute(only_validate: only_validate).merge(path: path)
  rescue => ex
    { status: false, path: path, message: ex.message }
  end


  def render_json(status_code = 200, status: status_code, data: nil, message: nil)
    render json: { status: status, data: data, message: message }, status: status_code
  end

  private

  def user_agent
    @user_agent ||= request.user_agent
  end

  def gitee_agent?
    user_agent == 'git-oschina-hook'
  end

  def quote_mark(message)
    <<~HEREDOC
    ```
    #{message}
    ```
    HEREDOC
  end

  def generate_yml_url(path)
    if gitee_agent?
      "#{GITEE_REPO}/raw/#{@branch}/#{path}"
    else
      "#{GITHUB_REPO.sub('github.com', 'raw.githubusercontent.com')}/#{@branch}/#{path}"
    end
  end

  def owner
    (gitee_agent? ? GITEE_REPO : GITHUB_REPO).split('/')[-2]
  end

  def repo
    (gitee_agent? ? GITEE_REPO : GITHUB_REPO).split('/')[-1]
  end

  def notify_on_pr(pr_number, message, domain: nil)
    if gitee_agent? || domain == 'gitee'
      gitee_notify_on_pr(owner, repo, pr_number, message)
    else
      github_notify_on_pr(owner, repo, pr_number, message)
    end
  rescue => ex
    logger.error("Failed to notify on pr #{pr_number}, #{ex.message}")
  end

  def auth_validate
    gitee_agent? ? gitee_webhook_verify : github_webhook_verify
  end
end
