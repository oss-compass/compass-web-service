module Common
  ORG_DIR = 'communities'
  SINGLE_DIR = 'single-repositories'
  COLLECTION_DIR = 'collections'
  EXPORT_CACHE_TTL = 3.day
  EXPORT_TASK_QUEUE = 'export_task_v1'
  SUBSCRIPTION_QUEUE = 'subscriptions_update_v1'
  HOOK_PASS = ENV.fetch('HOOK_PASS') { 'password' }
  PROXY = ENV.fetch('PROXY') { 'http://localhost:10807' }
  HOST = ENV.fetch('DEFAULT_HOST') { 'http://localhost:3000' }
  CELERY_SERVER = ENV.fetch('CELERY_SERVER') { 'http://localhost:8000' }
  ECHARTS_SERVER = ENV.fetch('ECHARTS_SERVER') { 'http://localhost:8084' }
  SUPPORT_DOMAINS = ['gitee.com', 'github.com', 'raw.githubusercontent.com']
  SUPPORT_DOMAIN_NAMES = ['gitee', 'github']
  BOT_NAME = ENV.fetch('BOT_NAME') { 'compass-bot' }
  BOT_EMAIL = ENV.fetch('BOT_EMAIL') { 'compass-bot@gitee.com' }
  GITEE_REPO = ENV.fetch('GITEE_WORKFLOW_REPO')
  GITHUB_REPO = ENV.fetch('GITHUB_WORKFLOW_REPO')
  META_REPO = ENV.fetch('WORKFLOW_REPO_NAME') { 'compass-projects-information' }
  ADMIN_WEB_TOKEN = ENV.fetch('ADMIN_WEB_TOKEN')
  ADMIN_SLACK_WEBHOOK = ENV.fetch('ADMIN_SLACK_WEBBHOOK') { nil }
  SAFELIST_IPS = (ENV.fetch('SAFELIST_IPS') { '' })&.split(',')
  RESTRICTED_LABEL_LIST = (ENV.fetch('RESTRICTED_LABEL_LIST') { '' })&.split(',')
  RESTRICTED_LABEL_VIEWERS = (ENV.fetch('RESTRICTED_LABEL_VIEWERS') { '' })&.split(',')

  Faraday.ignore_env_proxy = true

  def extract_domain(url)
    Addressable::URI.parse(url)&.normalized_host
  end

  def quote_mark(message)
    <<~HEREDOC
    ```
    #{message}
    ```
    HEREDOC
  end

  def gitee_agent?(agent)
    agent == 'git-oschina-hook'
  end

  def owner(agent)
    (gitee_agent?(agent) ? GITEE_REPO : GITHUB_REPO).split('/')[-2]
  end

  def repo(agent)
    (gitee_agent?(agent) ? GITEE_REPO : GITHUB_REPO).split('/')[-1]
  end

  def generate_yml_url(agent, branch, path)
    if gitee_agent?(agent)
      "#{GITEE_REPO}/raw/#{branch}/#{path}"
    else
      "#{GITHUB_REPO.sub('github.com', 'raw.githubusercontent.com')}/#{branch}/#{path}"
    end
  end

  def each_patch_with_action(diff_url, &action)
    req = { method: :get, url: diff_url }
    req[:proxy] = PROXY unless extract_domain(diff_url).start_with?('gitee')
    diff = RestClient::Request.new(req).execute.body
    patches = GitDiffParser.parse(diff)
    patches.each do |patch|
      action.call(patch)
    end
  end

  def analyze_or_submit_yaml_file(analyzer, user_agent, branch, path, extra={})

    yaml_url = generate_yml_url(user_agent, branch, path)
    is_org = extra[:is_org] || false
    pr_number = extra[:pr_number]
    only_validate = extra[:only_validate]

    base_config = {
      callback: {
        hook_url: "#{HOST}/api/hook",
        params: { pr_number: pr_number }
      }
    }
    params =
      if is_org
        base_config.merge(yaml_url: yaml_url)
      else
        req = { method: :get, url: yaml_url }
        req[:proxy] = PROXY unless extract_domain(yaml_url).start_with?('gitee')
        yaml = YAML.load(RestClient::Request.new(req).execute.body)
        base_config.merge(repo_url: yaml['resource_types']['repo_urls'], developers: yaml['developers'] || {})
      end
    ActiveRecord::Base.connection_pool.with_connection do
      analyzer.new(params).execute(only_validate: only_validate).merge(path: path)
    end
  rescue => ex
    { status: nil, message: ex.message, url: yaml_url }
  end

  def system_slack_notify(agent, pr_number, message)
    if ADMIN_SLACK_WEBHOOK.present?
      source = gitee_agent?(agent) ? GITEE_REPO : GITHUB_REPO
      body = {
        source: source,
        pr_number: pr_number,
        message: message
      }
      resp =
        Faraday.post(
          ADMIN_SLACK_WEBHOOK,
          { text: YAML.dump(body) }.to_json,
          { 'Content-Type' => 'application/json' }
        )
      Rails.logger.info(resp.body)
    end
  rescue => ex
    Rails.logger.error("Failed to notify system slack, #{ex.message}")
  end
end
