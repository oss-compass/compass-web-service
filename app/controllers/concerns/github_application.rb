module GithubApplication
  extend ActiveSupport::Concern
  include Common

  GITHUB_TOKEN = ENV.fetch('GITHUB_API_TOKEN')
  RAW_GITHUB_ENDPOINT = 'https://raw.githubusercontent.com'
  GITHUB_API_ENDPOINT = 'https://api.github.com'

  def github_notify_on_pr(owner, repo, pr_number, message)
    RestClient::Request.new(
      method: :post,
      url: "#{GITHUB_API_ENDPOINT}/repos/#{github_owner}/#{github_repo}/issues/#{pr_number}/comments",
      payload: { body: message }.to_json,
      headers: { 'Content-Type' => 'application/json' , 'Authorization' => "Bearer #{GITHUB_TOKEN}" },
      proxy: PROXY
    ).execute
  end

  def github_is_fork_repo(url)
    url = url.chomp('.git')
    namespace, repository = url.match(/github.com\/(.*)\/(.*)$/).captures
    resp =
      RestClient::Request.new(
        method: :get,
        url: "#{GITHUB_API_ENDPOINT}/repos/#{namespace}/#{repository}",
        headers: { 'Content-Type' => 'application/json' , 'Authorization' => "Bearer #{GITHUB_TOKEN}" },
        proxy: PROXY
      ).execute
    case JSON.load(resp.body).symbolize_keys
        in { fork: false }
        { status: true }
    else
      { status: false, message: I18n.t('oauth.validate.fork') }
    end
  rescue => ex
    { status: true, message: I18n.t('oauth.validate.retry', reason: ex.message) }
  end

  def github_get_user_info(token)
    resp =
      RestClient::Request.new(
        method: :get,
        url: "#{GITHUB_API_ENDPOINT}/user",
        headers: { 'Content-Type' => 'application/json' , 'Authorization' => "Bearer #{token}" },
        proxy: PROXY
      ).execute
    case JSON.load(resp.body).symbolize_keys
        in { login: username }
        { status: true, username: username }
    else
      { status: false, message: I18n.t('oauth.user.missing') }
    end
  rescue => ex
    { status: false, message: I18n.t('oauth.user.failed', reason: ex.message) }
  end

  def github_get_head_sha(ref_name: 'main')
    resp =
      RestClient::Request.new(
        method: :get,
        url: "#{GITHUB_API_ENDPOINT}/repos/#{github_owner}/#{github_repo}/git/refs/heads",
        headers: { 'Content-Type' => 'application/json' , 'Authorization' => "Bearer #{GITHUB_TOKEN}" },
        proxy: PROXY
      ).execute
    {
      status: true,
      sha: JSON.load(resp.body).select{|branch| branch['ref'] == "refs/heads/#{ref_name}"}.first['object']['sha']
    }
  rescue => ex
    { status: false, message: I18n.t('oauth.latest_sha.failed', reason: ex.message) }
  end

  def github_create_ref(branch_name, sha)
    RestClient::Request.new(
      method: :post,
      url: "#{GITHUB_API_ENDPOINT}/repos/#{github_owner}/#{github_repo}/git/refs",
      payload: { ref: "refs/heads/#{branch_name}", sha: sha }.to_json,
      headers: { 'Content-Type' => 'application/json' , 'Authorization' => "Bearer #{GITHUB_TOKEN}" },
      proxy: PROXY
    ).execute
    { status: true, ref: branch_name }
  rescue => ex
    { status: false, message: I18n.t('oauth.branch.failed', reason: ex.message) }
  end

  def github_get_file(path, branch)
    resp =
      RestClient::Request.new(
        method: :get,
        url: "#{RAW_GITHUB_ENDPOINT}/#{github_owner}/#{github_repo}/#{branch}/#{path}",
        headers: { 'Authorization' => "Bearer #{GITHUB_TOKEN}" },
        proxy: PROXY
      ).execute
    { status: true, body: resp.body }
  rescue => ex
    { status: false, message: I18n.t('oauth.user.failed', reason: ex.message) }
  end

  def github_put_file(path, message, content_base64, branch_name, sha: nil)
    signed_off_message = message + "\n\nSigned-off-by: #{BOT_NAME} <#{BOT_EMAIL}>"
    resp =
      RestClient::Request.new(
        method: :put,
        url: "#{GITHUB_API_ENDPOINT}/repos/#{github_owner}/#{github_repo}/contents/#{path}",
        payload: { message: signed_off_message, content: content_base64, branch: branch_name, sha: sha }.to_json,
        headers: { 'Content-Type' => 'application/json' , 'Authorization' => "Bearer #{GITHUB_TOKEN}" },
        proxy: PROXY
      ).execute
    { status: true, message: resp.body }
  rescue => ex
    if ex.message.include?('422')
      return { status: false, message: I18n.t('oauth.file.submitted') }
    end
    { status: false, message: I18n.t('oauth.file.failed', reason: ex.message) }
  end

  def github_create_pull(title, content, head, base: 'main')
    resp =
      RestClient::Request.new(
        method: :post,
        url: "#{GITHUB_API_ENDPOINT}/repos/#{github_owner}/#{github_repo}/pulls",
        payload: { title: title, body: content, head: head, base: base }.to_json,
        headers: { 'Content-Type' => 'application/json' , 'Authorization' => "Bearer #{GITHUB_TOKEN}" },
        proxy: PROXY
      ).execute
    pull = JSON.load(resp.body)
    { status: true, pr_id: pull['id'], pr_url: pull['html_url'] }
  rescue => ex
    { status: false, message: I18n.t('oauth.pull.failed', reason: ex.message) }
  end

  private

  def github_owner
    @github_owner ||= GITHUB_REPO.split('/')[-2]
  end

  def github_repo
    @github_repo ||= GITHUB_REPO.split('/')[-1]
  end

  def github_webhook_verify
    request.body.rewind
    payload_body = request.body.read
    signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), HOOK_PASS, payload_body)
    render_json(403, message: 'unauthorized') unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE_256'])
  end
end
