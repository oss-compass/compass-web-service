# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareReportMetricClarificationPermissionQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareReportMetricClarificationPermissionType, null: true
        description 'Get tpc software report metric clarification permission'

        argument :short_code, String, required: true
        argument :report_type, Integer, required: false, description: '0: selection 1:graduation 3:sandbox', default_value: '0'

        def resolve(short_code: nil, report_type: 0)
          current_user = context[:current_user]

          case report_type
          when TpcSoftwareMetricServer::Report_Type_Selection
            report = TpcSoftwareSelectionReport.where(report_type: TpcSoftwareSelectionReport::Report_Type_Incubation)
                                               .where("short_code = :code OR code_url = :url", code: short_code, url: short_code)
                                               .first
          when TpcSoftwareMetricServer::Report_Type_Graduation
            report = TpcSoftwareGraduationReport.where("short_code = :code OR code_url = :url", code: short_code, url: short_code)
                                                .first
          when TpcSoftwareMetricServer::Report_Type_Sandbox
            report = TpcSoftwareSandboxReport.where("short_code = :code OR code_url = :url", code: short_code, url: short_code)
                                                .first
          end
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report.nil?

          clarification_committer_permission = false
          clarification_sig_lead_permission = false
          clarification_legal_permission = false
          clarification_compliance_permission = false
          if current_user.present?
            clarification_committer_permission = TpcSoftwareMember.check_committer_permission?(report.tpc_software_sig_id, current_user)
            clarification_sig_lead_permission = TpcSoftwareMember.check_sig_lead_permission?(current_user)
            clarification_legal_permission = TpcSoftwareMember.check_legal_permission?(current_user)
            clarification_compliance_permission = TpcSoftwareMember.check_compliance_permission?(current_user)
            clarification_community_collaboration_wg_permission = TpcSoftwareMember.check_wg_permission?(current_user)
          end
          OpenStruct.new(
            {
              clarification_committer_permission: clarification_committer_permission ? 1 : 0,
              clarification_sig_lead_permission: clarification_sig_lead_permission ? 1 : 0,
              clarification_legal_permission: clarification_legal_permission ? 1 : 0,
              clarification_compliance_permission: clarification_compliance_permission ? 1 : 0,
              clarification_community_collaboration_wg_permission: clarification_community_collaboration_wg_permission ? 1 : 0
            }
          )
        end
      end
    end
  end
end
