module GiteeApplication
  extend ActiveSupport::Concern
  include Common

  GITEE_TOKEN = ENV.fetch('GITEE_API_TOKEN')
  GITEE_ENDPOINT = 'https://gitee.com'
  GITEE_API_ENDPOINT = 'https://gitee.com/api/v5'

  def gitee_notify_on_pr(owner, repo, pr_number, message)
      Faraday.post(
        "#{GITEE_API_ENDPOINT}/repos/#{owner}/#{repo}/pulls/#{pr_number}/comments",
        { body: message, access_token: GITEE_TOKEN }.to_json,
        { 'Content-Type' => 'application/json' }
      )
  end

  def gitee_is_fork_repo(url)
    url = url.chomp('.git')
    namespace, repository = url.match(/gitee.com\/([^\/]+)\/([^\/]+)$/).captures
    resp =
      Faraday.get(
        "#{GITEE_API_ENDPOINT}/repos/#{namespace}/#{repository}?access_token=#{GITEE_TOKEN}",
        { 'Content-Type' => 'application/json' },
      )
    case JSON.parse(resp.body).symbolize_keys
        in { fork: false }
        { status: true }
    else
      { status: false, message: I18n.t('oauth.validate.fork') }
    end
  rescue => ex
    { status: true, message: I18n.t('oauth.validate.retry', reason: ex.message) }
  end

  def gitee_get_user_info(token)
    resp =
      Faraday.get(
        "#{GITEE_API_ENDPOINT}/user?access_token=#{token}",
        { 'Content-Type' => 'application/json' }
      )
    case JSON.parse(resp.body).symbolize_keys
        in {login: username}
        { status: true, username: username }
    else
      { status: false, message: I18n.t('oauth.user.missing') }
    end
  rescue => ex
    { status: false, message: I18n.t('oauth.user.failed', reason: ex.message) }
  end

  def gitee_create_branch(branch_name, refs: 'main')
    Faraday.post(
      "#{GITEE_API_ENDPOINT}/repos/#{gitee_owner}/#{gitee_repo}/branches",
      { refs: refs, branch_name: branch_name, access_token: GITEE_TOKEN }.to_json,
      { 'Content-Type' => 'application/json' }
    )
    { status: true, ref: branch_name }
  rescue => ex
    { status: false, message: I18n.t('oauth.branch.failed', reason: ex.message) }
  end

  def gitee_get_file(path, branch)
    resp =
      Faraday.get("#{GITEE_ENDPOINT}/#{gitee_owner}/#{gitee_repo}/raw/#{branch}/#{path}")
    if resp.success?
      { status: true, body: resp.body }
    else
      { status: false, message: resp.body }
    end
  rescue => ex
    { status: false, message: I18n.t('oauth.user.failed', reason: ex.message) }
  end

  def gitee_post_file(path, message, content_base64, branch_name)
    signed_off_message = message + "\n\nSigned-off-by: #{BOT_NAME} <#{BOT_EMAIL}>"
    resp =
      Faraday.post(
        "#{GITEE_API_ENDPOINT}/repos/#{gitee_owner}/#{gitee_repo}/contents/#{path}",
        { message: signed_off_message, content: content_base64, branch: branch_name, access_token: GITEE_TOKEN }.to_json,
        { 'Content-Type' => 'application/json'}
      )
    case JSON.parse(resp.body).symbolize_keys
        in {commit: commit, content: content}
        { status: true, message: content['name']}
        in {message: message}
        { status: false, message: message }
    else
      { status: false, message: resp.body }
    end
  rescue => ex
    { status: false, message: I18n.t('oauth.file.failed', reason: ex.message) }
  end

  def gitee_put_file(path, message, content_base64, branch_name, sha)
    signed_off_message = message + "\n\nSigned-off-by: #{BOT_NAME} <#{BOT_EMAIL}>"
    resp =
      Faraday.put(
        "#{GITEE_API_ENDPOINT}/repos/#{gitee_owner}/#{gitee_repo}/contents/#{path}",
        { message: signed_off_message, content: content_base64, branch: branch_name, access_token: GITEE_TOKEN, sha: sha }.to_json,
        { 'Content-Type' => 'application/json'}
      )
    case JSON.parse(resp.body).symbolize_keys
        in {commit: commit, content: content}
        { status: true, message: content['name']}
        in {message: message}
        { status: false, message: message }
    else
      { status: false, message: resp.body }
    end
  rescue => ex
    { status: false, message: I18n.t('oauth.file.failed', reason: ex.message) }
  end

  def gitee_create_pull(title, content, head, base: 'main')
    resp =
      Faraday.post(
        "#{GITEE_API_ENDPOINT}/repos/#{gitee_owner}/#{gitee_repo}/pulls",
        {
          title: title,
          body: content,
          head: head,
          base: base,
          prune_source_branch: false,
          access_token: GITEE_TOKEN
        }.to_json,
        { 'Content-Type' => 'application/json'}
      )
    pull = JSON.parse(resp.body)
    { status: true, pr_id: pull['id'], pr_url: pull['html_url'] }
  rescue => ex
    { status: false, message: I18n.t('oauth.pull.failed', reason: ex.message) }
  end

  def gitee_create_org_repo(repo_url, gitee_token, description)
    Faraday.post(
      "#{GITEE_API_ENDPOINT}/orgs/#{gitee_owner(repo_url)}/repos",
      {
        name: gitee_repo(repo_url),
        description: description,
        public: 1,
        access_token: gitee_token
      }.to_json,
      { 'Content-Type' => 'application/json' }
    )
    { status: true, repo_url: repo_url }
  rescue => ex
    { status: false, message: I18n.t('oauth.org_repo.failed', reason: ex.message) }
  end

  def gitee_create_issue(repo_url, gitee_token, title, body)
    resp = Faraday.post(
      "#{GITEE_API_ENDPOINT}/repos/#{gitee_owner(repo_url)}/issues",
      {
        repo: gitee_repo(repo_url),
        title: title,
        body: body,
        access_token: gitee_token
      }.to_json,
      { 'Content-Type' => 'application/json' }
    )
    issue = JSON.parse(resp.body)
    Rails.logger.info "gitee_create_issue: #{issue}"
    { status: true, issue_url: issue["html_url"] }
  rescue => ex
    { status: false, message: I18n.t('oauth.issue.failed', reason: ex.message) }
  end

  def gitee_create_issue_comment(repo_url, gitee_token, number, body)
    resp = Faraday.post(
      "#{GITEE_API_ENDPOINT}/repos/#{gitee_owner(repo_url)}/#{gitee_repo(repo_url)}/issues/#{number}/comments",
      {
        body: body,
        access_token: gitee_token
      }.to_json,
      { 'Content-Type' => 'application/json' }
    )
    issue = JSON.parse(resp.body)
    Rails.logger.info "gitee_create_issue_comment: #{issue}"
    { status: true, message: '' }
  rescue => ex
    { status: false, message: I18n.t('oauth.issue.failed', reason: ex.message) }
  end

  def gitee_update_issue_title(repo_url, gitee_token, number, title)
    resp = Faraday.patch(
      "#{GITEE_API_ENDPOINT}/repos/#{gitee_owner(repo_url)}/issues/#{number}",
      {
        repo: gitee_repo(repo_url),
        title: title,
        access_token: gitee_token
      }.to_json,
      { 'Content-Type' => 'application/json' }
    )
    issue = JSON.parse(resp.body)
    Rails.logger.info "gitee_update_issue_title: #{issue}"
    { status: true, message: '' }
  rescue => ex
    { status: false, message: I18n.t('oauth.issue.failed', reason: ex.message) }
  end

  private
  def gitee_owner(gitee_repo = GITEE_REPO)
    @gitee_owner ||= gitee_repo.split('/')[-2]
  end

  def gitee_repo(gitee_repo = GITEE_REPO)
    @gitee_repo ||= gitee_repo.split('/')[-1]
  end


  def gitee_webhook_verify
    password = request.request_parameters&.[]('password')
    render_json(403, message: 'unauthorized') unless password == HOOK_PASS
  end
end
