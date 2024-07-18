# frozen_string_literal: true

module Mutations
  module Tpc
    class CreateTpcSoftwareReportMetricClarification < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :short_code, String, required: true
      argument :metric_name, String, required: true
      argument :content, String, required: true

      def resolve(short_code: nil,
                  metric_name: nil,
                  content: nil
      )
        current_user = context[:current_user]
        login_required!(current_user)

        report = TpcSoftwareSelectionReport.find_by(short_code: short_code)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report.nil?
        report_metric = TpcSoftwareReportMetric.find_by(
          tpc_software_report_id: report.id,
          tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection,
          version: TpcSoftwareReportMetric::Version_Default)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report_metric.nil?

        TpcSoftwareComment.create!(
          {
            tpc_software_id: report_metric.id,
            tpc_software_type: TpcSoftwareComment::Type_Report_Metric,
            user_id: current_user.id,
            subject_id: report_metric.subject_id,
            metric_name: metric_name,
            content: content
          }
        )


        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

    end
  end
end
