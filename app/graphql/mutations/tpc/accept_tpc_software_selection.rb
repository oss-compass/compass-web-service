# frozen_string_literal: true

module Mutations
  module Tpc
    class AcceptTpcSoftwareSelection < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :selection_id, Integer, required: true
      argument :state, Integer, required: true, description: 'reject: -1, cancel: 0, accept: 1', default_value: '1'
      argument :member_type, Integer, required: true, description: 'committer: 0, sig lead: 1', default_value: '0'


      def resolve(selection_id: nil, state: 1, member_type: 0)

        current_user = context[:current_user]
        login_required!(current_user)

        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') unless TpcSoftwareCommentState::States.include?(state)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') unless TpcSoftwareCommentState::Member_Types.include?(member_type)

        selection = TpcSoftwareSelection.find_by(id: selection_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if selection.nil?

        if member_type == TpcSoftwareCommentState::Member_Type_Committer && state != TpcSoftwareCommentState::State_Cancel
          committer_permission = TpcSoftwareCommentState.check_committer_permission_by_selection?(selection.tpc_software_selection_report_ids, current_user)
          raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless committer_permission
        elsif member_type == TpcSoftwareCommentState::Member_Type_Sig_Lead && state != TpcSoftwareCommentState::State_Cancel
          sig_lead_permission = TpcSoftwareCommentState.check_sig_lead_permission?(current_user)
          raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless sig_lead_permission
        end

        comment_state = TpcSoftwareCommentState.find_or_initialize_by(
          tpc_software_id: selection.id,
          tpc_software_type: TpcSoftwareCommentState::Type_Selection,
          metric_name: TpcSoftwareCommentState::Metric_Name_Selection,
          user_id: current_user.id,
          member_type: member_type)
        if state == TpcSoftwareCommentState::State_Cancel
          raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless comment_state.user_id == current_user.id
          comment_state.destroy
        else
          comment_state.update!(
            {
              tpc_software_id: selection.id,
              tpc_software_type: TpcSoftwareCommentState::Type_Selection,
              user_id: current_user.id,
              subject_id: selection.subject_id,
              metric_name: TpcSoftwareCommentState::Metric_Name_Selection,
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
