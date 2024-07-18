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

        review_permission = TpcSoftwareSelection.get_review_permission(selection)
        raise GraphQL::ExecutionError.new I18n.t('tpc.software_report_metric_not_clarified') unless review_permission

        if member_type == TpcSoftwareCommentState::Member_Type_Committer && state != TpcSoftwareCommentState::State_Cancel
          committer_permission = TpcSoftwareCommentState.check_committer_permission_by_selection?(
            JSON.parse(selection.tpc_software_selection_report_ids), current_user)
          raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless committer_permission
        elsif member_type == TpcSoftwareCommentState::Member_Type_Sig_Lead && state != TpcSoftwareCommentState::State_Cancel
          sig_lead_permission = TpcSoftwareCommentState.check_sig_lead_permission?(current_user)
          raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless sig_lead_permission
        end

        from_state = TpcSoftwareCommentState.get_state(selection.id, TpcSoftwareCommentState::Type_Selection, member_type)

        ActiveRecord::Base.transaction do
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
        end
        to_state = TpcSoftwareCommentState.get_state(selection.id, TpcSoftwareCommentState::Type_Selection, member_type)
        send_issue_comment(from_state, to_state, member_type, selection.issue_url, current_user)


        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

      def send_issue_comment(from_state, to_state, member_type, issue_url, current_user)
        member_type_content = member_type == TpcSoftwareCommentState::Member_Type_Committer ? "TPC垂域Committer" : "TPC SIG Leader"
        state_change = "#{from_state}->#{to_state}"
        case state_change
        when "-1->0"
          comment_content = "评审已取消"
        when "-1->1"
          comment_content = "评审通过"
        when "0->-1"
          comment_content = "评审拒绝"
        when "0->1"
          comment_content = "评审通过"
        when "1->-1"
          comment_content = "评审拒绝"
        when "1->0"
          comment_content = "评审已取消"
        else
          comment_content = nil
        end
        if comment_content.present? && issue_url.present?
          username = LoginBind.current_host_nickname(current_user, "gitee")
          if username.blank?
            username = LoginBind.current_host_nickname(current_user, "github")
          end

          issue_body = "#{member_type_content} @#{username} #{comment_content}"
          issue_url_list = issue_url.split("/issues/")
          subject_customization = SubjectCustomization.find_by(name: "OpenHarmony")
          if issue_url_list.length && subject_customization.present?
            repo_url = issue_url_list[0]
            number = issue_url_list[1]
            if repo_url.include?("gitee.com")
              IssueServer.new(
                {
                  repo_url: repo_url,
                  gitee_token: subject_customization.gitee_token,
                  github_token: nil
                }
              ).create_gitee_issue_comment(number, issue_body)
            end
          end
        end
      end
    end
  end
end
