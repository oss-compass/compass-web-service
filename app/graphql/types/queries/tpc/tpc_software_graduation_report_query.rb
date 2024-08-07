# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareGraduationReportQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareGraduationReportType, null: true
        description 'Get tpc software graduation report apply page'
        argument :short_code, String, required: true


        def resolve(short_code: nil)
          current_user = context[:current_user]

          report = TpcSoftwareGraduationReport.find_by(short_code: short_code)
          if report
            report_hash = report.attributes
            clarification_committer_permission = false
            clarification_sig_lead_permission = false
            clarification_legal_permission = false
            clarification_compliance_permission = false
            if current_user.present?
              clarification_committer_permission = TpcSoftwareMember.check_committer_permission?(report.tpc_software_sig_id, current_user)
              clarification_sig_lead_permission = TpcSoftwareMember.check_sig_lead_permission?(current_user)
              clarification_legal_permission = TpcSoftwareMember.check_legal_permission?(current_user)
              clarification_compliance_permission = TpcSoftwareMember.check_compliance_permission?(current_user)
            end

            report_hash['clarification_committer_permission'] = clarification_committer_permission ? 1 : 0
            report_hash['clarification_sig_lead_permission'] = clarification_sig_lead_permission ? 1 : 0
            report_hash['clarification_legal_permission'] = clarification_legal_permission ? 1 : 0
            report_hash['clarification_compliance_permission'] = clarification_compliance_permission ? 1 : 0
            report = OpenStruct.new(report_hash)
          end
          report
        end
      end
    end
  end
end
