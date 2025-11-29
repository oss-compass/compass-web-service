class ApplicationController < ActionController::Base

  skip_before_action :verify_authenticity_token

  include Pagy::Backend
  include Common
  include CompassUtils
  include GiteeApplication
  include GithubApplication

  before_action :set_locale
  before_action :gitee_webhook_verify, only: [:hook]
  before_action :auth_validate, only: [:workflow, :tpc_software_workflow]

  after_action { pagy_headers_merge(@pagy) if @pagy }

  def workflow
    payload = request.request_parameters

    action = payload['action']
    action_desc = payload['action_desc']
    merged_at = payload['pull_request']&.[]('merged_at')

    queue =
      case action
      when 'open', 'reopen', 'opened', 'synchronize'
        'yaml_check_v1'
      when 'update'
        if action_desc == 'source_branch_changed'
          'yaml_check_v1'
        end
      when 'merge'
        'submit_task_v1'
      when 'closed'
        if merged_at.present?
          'submit_task_v1'
        end
      end

    if queue
      RabbitMQ.publish(queue, { user_agent: user_agent, payload: payload })
    end

    render json: { status: true, message: I18n.t('dispatch.project.processed') }
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

  def tpc_software_workflow
    payload = request.request_parameters
    action = payload['action']
    hook_name = payload['hook_name']
    noteable_type = payload.dig('noteable_type') || ''
    if action == 'open' && hook_name == 'issue_hooks'
      TpcSoftwareMetricServer.create_issue_workflow(payload)
    elsif action == 'comment' && hook_name == 'note_hooks' && noteable_type == 'Issue'
      TpcSoftwareMetricServer.create_issue_comment_workflow(payload)
    end


    render json: { status: true, message: 'ok' }
  rescue => ex
    Rails.logger.info(ex)
    render json: { status: false, message: ex }
  end

  def tpc_software_callback
    payload = request.request_parameters


    command_list = payload['command_list']
    project_url = payload['project_url']
    scan_results = payload['scan_results'].to_h
    task_metadata = payload['task_metadata'].to_h
    report_id = task_metadata['report_id']
    report_metric_id = task_metadata['report_metric_id']
    report_type = task_metadata['report_type']
    version_number = task_metadata['version_number']
    metrics_model = task_metadata['metrics_model']

    Rails.logger.info("tpc_software_callback info: command_list: #{command_list} project_url: #{project_url} task_metadata: #{task_metadata}")

    metric_server = TpcSoftwareMetricServer.new({project_url: project_url.gsub(".git", "")})
    # 将所有openchecker内容保存到Opensearch
    metric_server.save_opencheck_raw_callback(command_list, scan_results)

    if report_type == TpcSoftwareMetricServer::Report_Type_Selection
      metric_server.tpc_software_selection_callback(command_list, scan_results, report_id, report_metric_id)
    elsif report_type == TpcSoftwareMetricServer::Report_Type_Graduation
      metric_server.tpc_software_graduation_callback(command_list, scan_results, report_id, report_metric_id)
    elsif report_type == TpcSoftwareMetricServer::Report_Type_License
      metric_server.tpc_software_license_callback(command_list, scan_results, version_number)
    elsif report_type == TpcSoftwareMetricServer::Report_Type_Metrics_Model
      metric_server.tpc_software_metrics_model_callback(metrics_model)
    elsif report_type == TpcSoftwareMetricServer::Report_Type_Sandbox
      metric_server.tpc_software_sandbox_callback(command_list, scan_results, report_id, report_metric_id)
    end

    render json: { status: true, message: 'ok' }
  rescue => ex
    Rails.logger.info(ex)
    render json: { status: false, message: ex }
  end


  def website
    render template: 'layouts/website'
  end

  def panel
    return redirect_to website_path unless user_signed_in?

    render template: 'layouts/panel'
  end

  protected

  def render_json(status_code = 200, status: status_code, data: nil, message: nil)
    render json: { status: status, data: data, message: message }, status: status_code
  end

  def notify_on_pr(pr_number, message, domain: nil)
    notify_method =
      gitee_agent?(user_agent) || domain == 'gitee' ?
        :gitee_notify_on_pr :
        :github_notify_on_pr
    self.send(notify_method, owner(user_agent), repo(user_agent), pr_number, message)
  rescue => ex
    Rails.logger.error("Failed to notify on pr #{pr_number}, #{ex.message}")
  end

  private

  def user_agent
    @user_agent ||= request.user_agent
  end

  def auth_validate
    gitee_agent?(user_agent) ? gitee_webhook_verify : github_webhook_verify
  end

  def set_locale
    locale = cookies[:locale].to_s.strip.to_sym
    locale = 'zh-CN'.to_sym if locale == :zh
    I18n.locale =
      I18n.available_locales.include?(locale) ?
        locale :
        I18n.default_locale
  end
end
