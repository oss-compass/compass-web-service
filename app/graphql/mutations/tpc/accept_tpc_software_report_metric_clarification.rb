# frozen_string_literal: true

module Mutations
  module Tpc
    class AcceptTpcSoftwareReportMetricClarification < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :short_code, String, required: true
      argument :report_type, Integer, required: false, description: '0: selection 1:graduation', default_value: '0'
      argument :metric_name, String, required: true
      argument :state, Integer, required: true, description: 'reject: -1, cancel: 0, accept: 1', default_value: '1'
      argument :member_type, Integer, required: true, description: 'committer: 0, sig lead: 1, legal: 2, compliance: 3', default_value: '0'


      def resolve(short_code: nil, report_type: 0, metric_name: nil, state: 1, member_type: 0)

        current_user = context[:current_user]
        login_required!(current_user)

        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') unless TpcSoftwareCommentState::States.include?(state)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') unless TpcSoftwareCommentState::Member_Types.include?(member_type)

        if state != TpcSoftwareCommentState::State_Cancel
          case member_type
          when TpcSoftwareCommentState::Member_Type_Committer
            permission = TpcSoftwareMember.check_committer_permission?(report.tpc_software_sig_id, current_user) &&
              !TpcSoftwareCommentState.check_compliance_metric(metric_name)
          when TpcSoftwareCommentState::Member_Type_Sig_Lead
            permission = TpcSoftwareMember.check_sig_lead_permission?(current_user) &&
              !TpcSoftwareCommentState.check_compliance_metric(metric_name)
          when TpcSoftwareCommentState::Member_Type_Legal
            permission = TpcSoftwareMember.check_legal_permission?(current_user) &&
              TpcSoftwareCommentState.check_compliance_metric(metric_name)
          when TpcSoftwareCommentState::Member_Type_Compliance
            permission = TpcSoftwareMember.check_compliance_permission?(current_user) &&
              TpcSoftwareCommentState.check_compliance_metric(metric_name)
          end
          raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless permission
        end

        case report_type
        when TpcSoftwareMetricServer::Report_Type_Selection
          report = TpcSoftwareSelectionReport.find_by(short_code: short_code)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report.nil?
          report_metric = TpcSoftwareReportMetric.find_by(
            tpc_software_report_id: report.id,
            tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection,
            version: TpcSoftwareReportMetric::Version_Default)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report_metric.nil?
          tpc_software_type = TpcSoftwareCommentState::Type_Report_Metric
        when report_type == TpcSoftwareMetricServer::Report_Type_Graduation
          report = TpcSoftwareGraduationReport.find_by(short_code: short_code)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report.nil?
          report_metric = TpcSoftwareGraduationReportMetric.find_by(
            tpc_software_report_id: report.id,
            version: TpcSoftwareReportMetric::Version_Default)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report_metric.nil?
          tpc_software_type = TpcSoftwareCommentState::Type_Graduation_Report_Metric
        end

        clarification_state = TpcSoftwareCommentState.find_or_initialize_by(
          tpc_software_id: report_metric.id,
          tpc_software_type: tpc_software_type,
          metric_name: metric_name,
          user_id: current_user.id)
        if state == TpcSoftwareCommentState::State_Cancel
          clarification_state.destroy
        else
          clarification_state.update!(
            {
              tpc_software_id: report_metric.id,
              tpc_software_type: tpc_software_type,
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
