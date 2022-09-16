module GiteeApplication
  extend ActiveSupport::Concern
  include Common

  GITEE_TOKEN = ENV.fetch('GITEE_API_TOKEN')
  GITEE_REPO = ENV.fetch('GITEE_WORKFLOW_REPO')
  GITEE_API_ENDPOINT = 'https://gitee.com/api/v5'

  private

  def gitee_webhook_verify
    password = request.request_parameters&.[]('password')
    render_json(403, message: 'unauthorized') unless password == HOOK_PASS
  end
end
