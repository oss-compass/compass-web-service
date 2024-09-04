# frozen_string_literal: true
class ChartTpcRenderServer
  include Common
  include CompassUtils

  def initialize(params = {})
    @code_url = params[:code_url]
    @report_type = params[:report_type]
  end

  def render
    total, compliance, ecology, lifecycle, security = case @report_type
                                                      when 'incubating'
                                                        render_tpc_incubating_chart
                                                      when 'graduation'
                                                        render_tpc_graduation_chart
                                                      else
                                                        render_tpc_incubating_chart
                                                      end
    payload = {
      global: total,
      legal: compliance,
      technology_ecosystem: ecology,
      lifecycle: lifecycle,
      security: security
    }
    token = tpc_service_token
    result = base_post_request("report-summary", payload, token: token)
    raise GraphQL::ExecutionError.new result[:message] unless result[:status]
    result[:body]
  end

  def render_tpc_incubating_chart
    report = TpcSoftwareSelectionReport.find_by(code_url: @code_url)
    raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report.nil?
    report_metric = TpcSoftwareReportMetric.find_by(
      tpc_software_report_id: report.id,
      tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection,
      version: TpcSoftwareReportMetric::Version_Default)
    report_metric.report_score
  end

  def render_tpc_graduation_chart
    report = TpcSoftwareGraduationReport.find_by(code_url: @code_url)
    raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report.nil?
    report_metric = TpcSoftwareGraduationReportMetric.find_by(
      tpc_software_graduation_report_id: report.id,
      version: TpcSoftwareGraduationReportMetric::Version_Default)
    report_metric.report_score
  end

  def tpc_service_token
    payload = {
      client_id: TPC_SERVICE_API_USERNAME,
      client_secret: TPC_SERVICE_API_PASSWORD
    }
    result = base_post_request("login", payload)
    raise GraphQL::ExecutionError.new result[:message] unless result[:status]
    JSON.parse(result[:body])["access_token"]
  end

  def base_post_request(request_path, payload, token: nil)
    header = { 'Content-Type' => 'application/json' }
    if token
      header["Authorization"] = "Bearer #{token}"
    end
    resp = RestClient::Request.new(
      method: :post,
      url: "#{ECHARTS_TPC_SERVER}/#{request_path}",
      payload: payload.to_json,
      headers: header,
      proxy: PROXY
    ).execute
    if resp.body.include?("error")
      { status: false, message: I18n.t('tpc.software_report_trigger_failed', reason: resp.body) }
    else
      { status: true, body: resp.body }
    end
  rescue => ex
    { status: false, message: I18n.t('tpc.software_report_trigger_failed', reason: ex.message) }
  end

end
