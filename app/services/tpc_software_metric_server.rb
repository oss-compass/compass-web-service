# frozen_string_literal: true

class TpcSoftwareMetricServer

  include Common
  include CompassUtils

  DEFAULT_HOST = ENV.fetch('DEFAULT_HOST')

  TPC_SERVICE_API_ENDPOINT = ENV.fetch('TPC_SERVICE_API_ENDPOINT')
  TPC_SERVICE_API_USERNAME = ENV.fetch('TPC_SERVICE_API_USERNAME')
  TPC_SERVICE_API_PASSWORD = ENV.fetch('TPC_SERVICE_API_PASSWORD')
  TPC_SERVICE_CALLBACK_URL = "#{DEFAULT_HOST}/api/tpc_software_callback"

  def initialize(opts = {})
    @project_url = opts[:project_url]
  end

  def analyze_metric_by_compass(report_id, report_metric_id)
    result = AnalyzeServer.new(
      {
        repo_url: @project_url,
        callback: {
          hook_url: TPC_SERVICE_CALLBACK_URL,
          params: {
            callback_type: "tpc_software_callback",
            task_metadata: {
              report_id: report_id,
              report_metric_id: report_metric_id
            }
          }
        }
      }
    ).simple_execute
    Rails.logger.info("analyze metric by compass info: #{result}")
    raise GraphQL::ExecutionError.new result[:message] unless result[:status]
  end

  def analyze_metric_by_tpc_service(report_id, report_metric_id)
    token = tpc_service_token
    commands = ["osv-scanner", "scancode", "binary-checker", "signature-checker", "sonar-scanner"]
    payload = {
      commands: commands,
      project_url: "#{@project_url}.git",
      callback_url: TPC_SERVICE_CALLBACK_URL,
      task_metadata: {
        report_id: report_id,
        report_metric_id: report_metric_id
      }
    }
    result = base_post_request("opencheck", payload, token: token)
    Rails.logger.info("analyze metric by tpc service info: #{result}")
    raise GraphQL::ExecutionError.new result[:message] unless result[:status]
  end

  def tpc_software_callback(command_list, scan_results, task_metadata)
    code_count = nil
    license = nil

    # commands = ["osv-scanner", "scancode", "binary-checker", "signature-checker", "sonar-scanner", "compass"]
    metric_hash = Hash.new
    command_list.each do |command|
      case command
      when "osv-scanner"
        metric_hash.merge!(TpcSoftwareReportMetric.get_security_vulnerability(scan_results.dig(command)) || {})
      when "scancode"
        metric_hash.merge!(TpcSoftwareReportMetric.get_compliance_license(@project_url, scan_results.dig(command)))
        metric_hash.merge!(TpcSoftwareReportMetric.get_compliance_license_compatibility(scan_results.dig(command)) || {})
        license = TpcSoftwareReportMetric.get_license(@project_url, scan_results.dig(command) || {})
      when "binary-checker"
        metric_hash.merge!(TpcSoftwareReportMetric.get_security_binary_artifact(scan_results.dig(command) || {}))
      when "signature-checker"
        metric_hash.merge!(TpcSoftwareReportMetric.get_compliance_package_sig(scan_results.dig(command) || {}))
      when "sonar-scanner"
        metric_hash.merge!(TpcSoftwareReportMetric.get_ecology_software_quality(scan_results.dig(command) || {}))
        code_count = TpcSoftwareReportMetric.get_code_count(scan_results.dig(command) || {})
      when "compass"
        metric_hash.merge!(TpcSoftwareReportMetric.get_compliance_dco(@project_url))
        metric_hash.merge!(TpcSoftwareReportMetric.get_ecology_code_maintenance(@project_url))
        metric_hash.merge!(TpcSoftwareReportMetric.get_ecology_community_support(@project_url))
        metric_hash.merge!(TpcSoftwareReportMetric.get_security_history_vulnerability(@project_url))
        metric_hash.merge!(TpcSoftwareReportMetric.get_lifecycle_version_lifecycle(@project_url))
      else
        raise GraphQL::ExecutionError.new I18n.t('tpc.callback_command_not_exist', command: command)
      end
    end
    report_metric_id = task_metadata["report_metric_id"]
    tpc_software_report_metric = TpcSoftwareReportMetric.find_by(id: report_metric_id)
    raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if tpc_software_report_metric.nil?

    report_metric_data = metric_hash
    if command_list.include?("compass")
      report_metric_data["status_compass_callback"] = 1
      if tpc_software_report_metric.status_tpc_service_callback == 1
        report_metric_data["status"] = TpcSoftwareReportMetric::Status_Success
      end
    else
      report_metric_data["status_tpc_service_callback"] = 1
      if tpc_software_report_metric.status_compass_callback == 1
        report_metric_data["status"] = TpcSoftwareReportMetric::Status_Success
      end
    end
    ActiveRecord::Base.transaction do
      tpc_software_report_metric.update!(report_metric_data)

      tpc_software_selection_report = TpcSoftwareSelectionReport.find_by(id: task_metadata["report_id"])
      update_data = {}
      update_data[:code_count] = code_count unless code_count.nil?
      update_data[:license] = license unless license.nil?
      if update_data.present?
        tpc_software_selection_report.update!(update_data)
      end
    end
  end

  def tpc_service_token
    payload = {
      username: TPC_SERVICE_API_USERNAME,
      password: TPC_SERVICE_API_PASSWORD
    }
    result = base_post_request("auth", payload)
    raise GraphQL::ExecutionError.new result[:message] unless result[:status]
    result[:body]["access_token"]
  end

  def base_post_request(request_path, payload, token: nil)
    header = { 'Content-Type' => 'application/json' }
    if token
      header["Authorization"] = "JWT #{token}"
    end
    resp = RestClient::Request.new(
      method: :post,
      url: "#{TPC_SERVICE_API_ENDPOINT}/#{request_path}",
      payload: payload.to_json,
      headers: header,
      proxy: PROXY
    ).execute
    resp_hash = JSON.parse(resp.body)
    if resp.body.include?("error")
      { status: false, message: I18n.t('tpc.software_report_trigger_failed', reason: resp_hash['description']) }
    else
      { status: true, body: resp_hash }
    end
  rescue => ex
    { status: false, message: I18n.t('tpc.software_report_trigger_failed', reason: ex.message) }
  end

end
