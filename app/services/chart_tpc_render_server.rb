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

    Faraday.post(
      "#{ECHARTS_TPC_SERVER}",
      payload.to_json,
      { 'Content-Type' => 'application/json'}
    ).body
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

end
