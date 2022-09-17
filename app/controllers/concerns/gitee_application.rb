module GiteeApplication
  extend ActiveSupport::Concern
  include Common

  GITEE_TOKEN = ENV.fetch('GITEE_API_TOKEN')
  GITEE_REPO = ENV.fetch('GITEE_WORKFLOW_REPO')
  GITEE_API_ENDPOINT = 'https://gitee.com/api/v5'

  def gitee_notify_on_pr(owner, repo, pr_number, message)
      Faraday.post(
        "#{GITEE_API_ENDPOINT}/repos/#{owner}/#{repo}/pulls/#{pr_number}/comments",
        { body: message, access_token: GITEE_TOKEN }.to_json,
        { 'Content-Type' => 'application/json' }
      )
  end

  private

  def gitee_webhook_verify
    password = request.request_parameters&.[]('password')
    render_json(403, message: 'unauthorized') unless password == HOOK_PASS
  end
end
