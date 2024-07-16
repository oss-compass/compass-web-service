# frozen_string_literal: true

module Mutations
  module Tpc
    class AcceptTpcSoftwareReportMetricClarification < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :short_code, String, required: true
      argument :metric_name, String, required: true
      argument :state, Integer, required: true, description: 'reject: -1, cancel: 0, accept: 1', default_value: '1'
      argument :member_type, Integer, required: true, description: 'committer: 0, sig lead: 1', default_value: '0'


      def resolve(short_code: nil, metric_name: nil, state: 1, member_type: 0)

        current_user = context[:current_user]
        login_required!(current_user)

        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') unless TpcSoftwareReportMetricClarificationState::States.include?(state)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') unless TpcSoftwareReportMetricClarificationState::Member_Types.include?(member_type)

        report = TpcSoftwareSelectionReport.find_by(short_code: short_code)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report.nil?

        report_metric = TpcSoftwareReportMetric.find_by(
          tpc_software_report_id: report.id,
          tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection,
          version: TpcSoftwareReportMetric::Version_Default)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report_metric.nil?

        if member_type == TpcSoftwareReportMetricClarificationState::Member_Type_Committer && state != TpcSoftwareReportMetricClarificationState::State_Cancel
          committer_permission = TpcSoftwareReportMetricClarificationState.check_committer_permission?(report.tpc_software_sig_id, current_user)
          raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless committer_permission
        elsif member_type == TpcSoftwareReportMetricClarificationState::Member_Type_Sig_Lead && state != TpcSoftwareReportMetricClarificationState::State_Cancel
          sig_lead_permission = TpcSoftwareReportMetricClarificationState.check_sig_lead_permission?(current_user)
          raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless sig_lead_permission
        end

        clarification_state = TpcSoftwareReportMetricClarificationState.find_or_initialize_by(
          tpc_software_report_metric_id: report_metric.id,
          metric_name: metric_name,
          user_id: current_user.id,
          member_type: member_type)
        if state == TpcSoftwareReportMetricClarificationState::State_Cancel
          raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless clarification_state.user_id == current_user.id
          clarification_state.destroy
        else
          clarification_state.update!(
            {
              tpc_software_report_metric_id: report_metric.id,
              user_id: current_user.id,
              subject_id: report_metric.subject_id,
              metric_name: metric_name,
              state: state,
              member_type: member_type
            }
          )
        end

        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

    end
  end
end
