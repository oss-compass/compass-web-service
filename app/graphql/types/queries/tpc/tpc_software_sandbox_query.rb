# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareSandboxQuery < BaseQuery
        include Pagy::Backend

        # type Types::Tpc::TpcSoftwareSelectionType, null: true
        type Types::Tpc::TpcSoftwareSandboxType, null: true
        description 'Get tpc software sandbox'
        argument :sandbox_id, Integer, required: true

        def resolve(sandbox_id: nil)
          current_user = context[:current_user]

          sandbox = TpcSoftwareSandbox.find_by(id: sandbox_id)
          if sandbox
            sandbox_hash = sandbox.attributes
            committer_permission = false
            sig_lead_permission = false
            legal_permission = false
            compliance_permission = false
            qa_permission = false
            if current_user.present?
              sandbox_report = TpcSoftwareSandboxReport.where("id IN (?)", JSON.parse(sandbox.tpc_software_sandbox_report_ids))
                                                           .where("code_url LIKE ?", "%#{sandbox.target_software}%")
                                                           .take
              if sandbox_report
                committer_permission = TpcSoftwareMember.check_committer_permission?(sandbox_report.tpc_software_sig_id, current_user)
              end
              sig_lead_permission = TpcSoftwareMember.check_sig_lead_permission?(current_user)
              legal_permission = TpcSoftwareMember.check_legal_permission?(current_user)
              compliance_permission = TpcSoftwareMember.check_compliance_permission?(current_user)
              qa_permission = TpcSoftwareMember.check_qa_permission?(current_user)
              # wg_permission = TpcSoftwareMember.check_wg_permission?(current_user)
            end

            sandbox_hash['comment_committer_permission'] = committer_permission ? 1 : 0
            sandbox_hash['comment_sig_lead_permission'] = sig_lead_permission ? 1 : 0
            sandbox_hash['comment_legal_permission'] = legal_permission ? 1 : 0
            sandbox_hash['comment_compliance_permission'] = compliance_permission ? 1 : 0
            sandbox_hash['comment_qa_permission'] = qa_permission ? 1 : 0
            # sandbox_hash['comment_community_collaboration_wg_permission'] = wg_permission ? 1 : 0
            report = OpenStruct.new(sandbox_hash)
          end
          report

        end
      end
    end
  end
end
