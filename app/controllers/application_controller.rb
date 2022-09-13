class ApplicationController < ActionController::Base

  HOOK_PASS = ENV.fetch('HOOK_PASS') { 'password' }
  GITEE_TOKEN = ENV.fetch('GITEE_API_TOKEN')
  GITHUB_TOKEN = ENV.fetch('GITHUB_API_TOKEN')
  GITEE_REPO = ENV.fetch('GITEE_WORKFLOW_REPO')
  GITHUB_REPO = ENV.fetch('GITHUB_WORKFLOW_REPO')
  GITEE_API_ENDPOINT = "https://gitee.com/api/v5"

  skip_before_action :verify_authenticity_token
  include Pagy::Backend

  before_action :validate_password, only: [:template]

  after_action { pagy_headers_merge(@pagy) if @pagy }

  def workflow
    payload = request.request_parameters
    @user_agent = request.user_agent

    action = payload['action']
    action_desc = payload['action_desc']
    pr_number = payload['iid']
    result =
      case action
      when 'open', 'reopen'
        check_yaml(payload)
      when 'update'
        if action_desc == 'source_branch_changed'
          check_yaml(payload)
        end
      when 'merge'
        submit_task(payload)
      end

    notify_on_pr(pr_number, result.to_json)

    render json: result
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
    @source_branch = payload&.[]('source_branch')
    if diff_url.present?
      result = []
      diff = Faraday.get(diff_url).body
      patches = GitDiffParser.parse(diff)
      patches.each do |patch|
        result << check_yaml_file(patch.file)
      end
      { status: true, message: 'ok', result: result }
    else
      { status: false, message: 'invalid diff url' }
    end
  rescue => ex
    { status: false, message: ex.message }
  end

  def check_yaml_file(path)
    yaml_url = generate_yml_url(path)
    yaml = YAML.load(Faraday.get(yaml_url).body)
    AnalyzeServer.new(
      {
        repo_url: yaml['data_sources']['repo_name'],
        raw: true,
        enrich: true,
        activity: true,
        community: true,
        codequality: true
      }
    ).execute(only_validate: true).merge(path: path)
  rescue => ex
    { status: false, path: path, message: ex.message }
  end

  def submit_task(payload)
    { status: true, message: 'ok' }
  end


  def render_json(status_code = 200, status: status_code, data: nil, message: nil)
    render json: { status: status, data: data, message: message }, status: status_code
  end

  private

  def generate_yml_url(path)
    if @user_agent == 'git-oschina-hook'
      "#{GITEE_REPO}/raw/#{@source_branch}/#{path}"
    else
      "#{GITHUB_REPO.sub('github.com', 'raw.githubusercontent.com')}/#{@source_branch}/#{path}"
    end
  end

  def repo_owner
    (@user_agent == 'git-oschina-hook' ? GITEE_REPO : GITHUB_REPO).split('/')[-2]
  end

  def repo_path
    (@user_agent == 'git-oschina-hook' ? GITEE_REPO : GITHUB_REPO).split('/')[-1]
  end

  def notify_on_pr(pr_number, message)
    if @user_agent == 'git-oschina-hook'
      note_url = "#{GITEE_API_ENDPOINT}/repos/#{repo_owner}/#{repo_path}/pulls/#{pr_number}/comments"
      Faraday.post(
        note_url,
        { body: message, access_token: GITEE_TOKEN }.to_json,
        { 'Content-Type' => 'application/json' }
      )
    else
      puts "no implentment"
    end
  rescue => ex
    logger.error("Failed to notify on pr #{pr_number}, #{ex.message}")
  end

  def validate_password
    password = request.request_parameters&.[]('password')
    render_json(403, message: 'unauthorized') unless password == HOOK_PASS
  end
end
