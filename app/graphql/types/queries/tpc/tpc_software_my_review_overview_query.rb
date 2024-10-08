# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareMyReviewOverviewQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareMyCreationAndReviewOverviewType, null: true
        description 'Get tpc software my review overview'
        argument :label, String, required: false, description: 'repo or project label'
        argument :level, String, required: false, description: 'repo or project level(repo/community)'

        def resolve(label: nil, level: nil)
          subject = Subject.find_by(label: label, level: level)

          current_user = context[:current_user]
          validate_tpc!(current_user)

          awaiting_clarification_count = 0
          awaiting_confirmation_count = 0
          awaiting_review_count = 0
          completed_count = 0
          rejected_count = 0
          incubation_count = 0
          graduation_count = 0
          [TpcSoftwareSelection, TpcSoftwareGraduation].each { |tpc_software|
            if TpcSoftwareMember.check_sig_lead_permission?(current_user) || 
              TpcSoftwareMember.check_legal_permission?(current_user) || 
              TpcSoftwareMember.check_compliance_permission?(current_user)
              base_query = tpc_software.where(subject_id: subject.id).where.not(issue_url: nil).where.not(state: nil)
            else
              committer_list = TpcSoftwareMember.get_committer_list(current_user, subject.id)
              if committer_list.present?
                sig_id_list = committer_list.map { |committer| committer.tpc_software_sig_id }
                if tpc_software == TpcSoftwareSelection
                  base_query = tpc_software.joins(tpc_software_selection_report: :tpc_software_sig)
                                           .where(subject_id: subject.id)
                                           .where.not(state: nil)
                                           .where.not(issue_url: nil)
                                           .where(tpc_software_selection_report: { tpc_software_sig_id: sig_id_list })
                elsif tpc_software == TpcSoftwareGraduation
                  base_query = tpc_software.joins(tpc_software_graduation_report: :tpc_software_sig)
                                           .where(subject_id: subject.id)
                                           .where.not(state: nil)
                                           .where.not(issue_url: nil)
                                           .where(tpc_software_graduation_report: { tpc_software_sig_id: sig_id_list })
                end
              else
                break
              end
            end

            awaiting_clarification_count += base_query.where(state: TpcSoftwareSelection::State_Awaiting_Clarification).count
            awaiting_confirmation_count += base_query.where(state: TpcSoftwareSelection::State_Awaiting_Confirmation).count
            awaiting_review_count += base_query.where(state: TpcSoftwareSelection::State_Awaiting_Review).count
            completed_count += base_query.where(state: TpcSoftwareSelection::State_Completed).count
            rejected_count += base_query.where(state: TpcSoftwareSelection::State_Rejected).count
            if tpc_software == TpcSoftwareSelection
              incubation_count = base_query.count
            elsif tpc_software == TpcSoftwareGraduation
              graduation_count = base_query.count
            end
          }

          OpenStruct.new(
            {
              total_count: awaiting_clarification_count + awaiting_confirmation_count + awaiting_review_count + completed_count + rejected_count,
              awaiting_clarification_count: awaiting_clarification_count,
              awaiting_confirmation_count: awaiting_confirmation_count,
              awaiting_review_count: awaiting_review_count,
              completed_count: completed_count,
              rejected_count: rejected_count,
              incubation_count: incubation_count,
              graduation_count: graduation_count
            }
          )
        end
      end
    end
  end
end
