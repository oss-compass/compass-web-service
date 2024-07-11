# frozen_string_literal: true

module Mutations
  module Tpc
    class AcceptTpcSoftwareReportMetricClarification < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :short_code, String, required: true
      argument :metric_name, String, required: true

      def resolve(short_code: nil,
                  metric_name: nil
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
        clarification_permission = TpcSoftwareReportMetricClarificationState.check_permission?(report.tpc_software_sig_id, current_user)
        raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless clarification_permission

        clarification_state = TpcSoftwareReportMetricClarificationState.find_or_initialize_by(
          tpc_software_report_metric_id: report_metric.id, metric_name: metric_name)
        clarification_state.update!(
          {
            tpc_software_report_metric_id: report_metric.id,
            user_id: current_user.id,
            subject_id: report_metric.subject_id,
            metric_name: metric_name,
            state: TpcSoftwareReportMetricClarificationState::State_Accept
          }
        )

        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

    end
  end
end
