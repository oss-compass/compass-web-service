# frozen_string_literal: true

module Mutations
  module Tpc
    class TriggerTpcSoftwareGraduationReport < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :report_id, Integer, required: true

      def resolve(report_id: nil)
        current_user = context[:current_user]
        login_required!(current_user)

        graduation_report = TpcSoftwareGraduationReport.find_by(id: report_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if graduation_report.nil?
        raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless current_user&.is_admin? || graduation_report.user_id == current_user.id
        report_metric = graduation_report.tpc_software_graduation_report_metrics.find_by(version: TpcSoftwareReportMetric::Version_Default)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report_metric.nil?

        ActiveRecord::Base.transaction do
          report_metric.update!(
            {
              status: TpcSoftwareGraduationReportMetric::Status_Again_Progress,
              status_compass_callback: 0,
              status_tpc_service_callback: 0
            }
          )
          metric_server = TpcSoftwareMetricServer.new({project_url: graduation_report.code_url})
          metric_server.analyze_metric_by_tpc_service(graduation_report.id, report_metric.id,graduation_report.oh_commit_sha, TpcSoftwareMetricServer::Report_Type_Graduation)
          metric_server.analyze_metric_by_compass(graduation_report.id, report_metric.id, TpcSoftwareMetricServer::Report_Type_Graduation)
        end


        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

    end
  end
end
