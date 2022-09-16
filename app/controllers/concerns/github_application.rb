module GithubApplication
  extend ActiveSupport::Concern
  include Common

  GITHUB_TOKEN = ENV.fetch('GITHUB_API_TOKEN')
  GITHUB_REPO = ENV.fetch('GITHUB_WORKFLOW_REPO')
  GITHUB_API_ENDPOINT = 'https://api.github.com'

  private

  def github_webhook_verify
    request.body.rewind
    payload_body = request.body.read
    signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), HOOK_PASS, payload_body)
    render_json(403, message: 'unauthorized') unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE_256'])
  end
end
