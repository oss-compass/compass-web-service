# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareMyCreationOverviewQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareMyCreationAndReviewOverviewType, null: true
        description 'Get tpc software my creation overview'
        argument :label, String, required: true, description: 'repo or project label'
        argument :level, String, required: true, description: 'repo or project level(repo/community)'

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
            base_query = tpc_software.where(subject_id: subject.id).where(user_id: current_user.id).where.not(issue_url: nil).where.not(state: nil)
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
