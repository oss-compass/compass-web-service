module GithubApplication
  extend ActiveSupport::Concern
  include Common

  GITHUB_TOKEN = ENV.fetch('GITHUB_API_TOKEN')
  GITHUB_REPO = ENV.fetch('GITHUB_WORKFLOW_REPO')
  GITHUB_API_ENDPOINT = 'https://api.github.com'

  def github_notify_on_pr(owner, repo, pr_number, message)
    RestClient.proxy = PROXY
    RestClient.post(
      "#{GITHUB_API_ENDPOINT}/repos/#{github_owner}/#{github_repo}/issues/#{pr_number}/comments",
      { body: message }.to_json,
      { 'Content-Type' => 'application/json' , 'Authorization' => "Bearer #{GITHUB_TOKEN}" }
    )
  end

  def github_get_head_sha(ref_name: 'main')
    RestClient.proxy = PROXY
    resp =
      RestClient.get(
        "#{GITHUB_API_ENDPOINT}/repos/#{github_owner}/#{github_repo}/git/refs/heads",
        { 'Content-Type' => 'application/json' , 'Authorization' => "Bearer #{GITHUB_TOKEN}" }
      )
    {
      status: true,
      sha: JSON.load(resp.body).select{|branch| branch['ref'] == "refs/heads/#{ref_name}"}.first['object']['sha']
    }
  rescue
    { status: false, message: 'failed to get latest sha' }
  end

  def github_create_ref(branch_name, sha)
    RestClient.proxy = PROXY
    RestClient.post(
      "#{GITHUB_API_ENDPOINT}/repos/#{github_owner}/#{github_repo}/git/refs",
      { ref: "refs/heads/#{branch_name}", sha: sha }.to_json,
      { 'Content-Type' => 'application/json' , 'Authorization' => "Bearer #{GITHUB_TOKEN}" }
    )
    { status: true, ref: branch_name }
  rescue => ex
    { status: false, message: "failed to create ref, reason: #{ex.message}" }
  end

  def github_put_file(path, message, content_base64, branch_name)
    RestClient.proxy = PROXY
    resp =
      RestClient.put(
        "#{GITHUB_API_ENDPOINT}/repos/#{github_owner}/#{github_repo}/contents/#{path}",
        { message: message, content: content_base64, branch: branch_name }.to_json,
        { 'Content-Type' => 'application/json' , 'Authorization' => "Bearer #{GITHUB_TOKEN}" }
      )
    { status: true, message: resp.body }
  rescue => ex
    if ex.message.include?('422')
      return { status: false, message: "alreadly sumbitted" }
    end
    { status: false, message: "failed to put file, reason: #{ex.message}" }
  end

  def github_create_pull(title, content, head, base: 'main')
    RestClient.proxy = PROXY
    resp =
      RestClient.post(
        "#{GITHUB_API_ENDPOINT}/repos/#{github_owner}/#{github_repo}/pulls",
        { title: title, body: content, head: head, base: base }.to_json,
        { 'Content-Type' => 'application/json' , 'Authorization' => "Bearer #{GITHUB_TOKEN}" }
      )
    pull = JSON.load(resp.body)
    { status: true, pr_id: pull['id'], pr_url: pull['html_url'] }
  rescue => ex
    { status: false, message: "failed to create ref, reason: #{ex.message}" }
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
