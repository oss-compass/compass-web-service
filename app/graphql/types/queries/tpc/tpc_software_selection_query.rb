# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareSelectionQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareSelectionType, null: true
        description 'Get tpc software selection'
        argument :selection_id, Integer, required: true

        def resolve(selection_id: nil)
          current_user = context[:current_user]

          selection = TpcSoftwareSelection.find_by(id: selection_id)
          if selection
            selection_hash = selection.attributes
            committer_permission = false
            sig_lead_permission = false
            legal_permission = false
            compliance_permission = false
            if current_user.present?
              selection_report = TpcSoftwareSelectionReport.where("id IN (?)", JSON.parse(selection.tpc_software_selection_report_ids))
                                                           .where("code_url LIKE ?", "%#{selection.target_software}%")
                                                           .take
              if selection_report
                committer_permission = TpcSoftwareMember.check_committer_permission?(selection_report.tpc_software_sig_id, current_user)
              end
              sig_lead_permission = TpcSoftwareMember.check_sig_lead_permission?(current_user)
              legal_permission = TpcSoftwareMember.check_legal_permission?(current_user)
              compliance_permission = TpcSoftwareMember.check_compliance_permission?(current_user)
            end

            selection_hash['comment_committer_permission'] = committer_permission ? 1 : 0
            selection_hash['comment_sig_lead_permission'] = sig_lead_permission ? 1 : 0
            selection_hash['comment_legal_permission'] = legal_permission ? 1 : 0
            selection_hash['comment_compliance_permission'] = compliance_permission ? 1 : 0
            report = OpenStruct.new(selection_hash)
          end
          report

        end
      end
    end
  end
end
