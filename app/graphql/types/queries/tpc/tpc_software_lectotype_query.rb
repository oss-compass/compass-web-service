# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareLectotypeQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareLectotypeType, null: true
        description 'Get tpc software lectotype'
        argument :lectotype_id, Integer, required: true

        def resolve(lectotype_id: nil)
          current_user = context[:current_user]

          lectotype = TpcSoftwareLectotype.find_by(id: lectotype_id)
          if lectotype
            lectotype_hash = lectotype.attributes
            committer_permission = false
            sig_lead_permission = false
            legal_permission = false
            compliance_permission = false
            qa_permission = false
            if current_user.present?
              lectotype_report = TpcSoftwareLectotypeReport.where("id IN (?)", JSON.parse(lectotype.tpc_software_lectotype_report_ids))
                                                           .where("code_url LIKE ?", "%#{lectotype.target_software}%")
                                                           .take
              if lectotype_report
                committer_permission = TpcSoftwareMember.check_committer_permission?(lectotype_report.tpc_software_sig_id, current_user)
              end
              sig_lead_permission = TpcSoftwareMember.check_sig_lead_permission?(current_user)
              legal_permission = TpcSoftwareMember.check_legal_permission?(current_user)
              compliance_permission = TpcSoftwareMember.check_compliance_permission?(current_user)
              qa_permission = TpcSoftwareMember.check_qa_permission?(current_user)
            end

            lectotype_hash['comment_committer_permission'] = committer_permission ? 1 : 0
            lectotype_hash['comment_sig_lead_permission'] = sig_lead_permission ? 1 : 0
            lectotype_hash['comment_legal_permission'] = legal_permission ? 1 : 0
            lectotype_hash['comment_compliance_permission'] = compliance_permission ? 1 : 0
            lectotype_hash['comment_qa_permission'] = qa_permission ? 1 : 0
            report = OpenStruct.new(lectotype_hash)
          end
          report

        end
      end
    end
  end
end
