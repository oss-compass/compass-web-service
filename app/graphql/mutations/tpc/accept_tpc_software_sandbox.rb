# frozen_string_literal: true

module Mutations
  module Tpc
    class AcceptTpcSoftwareSandbox < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :sandbox_id, Integer, required: true
      argument :state, Integer, required: true, description: 'reject: -1, cancel: 0, accept: 1', default_value: '1'
      argument :member_type, Integer, required: true, description: 'committer: 0, sig lead: 1, legal: 2, compliance: 3, qa:4', default_value: '0'


      def resolve(sandbox_id: nil, state: 1, member_type: 0)

        current_user = context[:current_user]
        validate_tpc!(current_user)

        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') unless TpcSoftwareCommentState::States.include?(state)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') unless TpcSoftwareCommentState::Member_Types_QA.include?(member_type)

        sandbox = TpcSoftwareSandbox.find_by(id: sandbox_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if sandbox.nil?

        if state == TpcSoftwareCommentState::State_Accept
          review_permission = TpcSoftwareSandbox.get_review_permission(sandbox, member_type)
          # raise GraphQL::ExecutionError.new I18n.t('tpc.software_report_metric_not_clarified') unless review_permission
        end


        if state != TpcSoftwareCommentState::State_Cancel
          case member_type
          # when TpcSoftwareCommentState::Member_Type_Committer
          #   sandbox_report = TpcSoftwareSandboxReport.where("id IN (?)", JSON.parse(sandbox.tpc_software_sandbox_report_ids))
          #                                                .where("code_url LIKE ?", "%#{sandbox.target_software}%")
          #                                                .take
          #   permission = 0
          #   if sandbox_report
          #     permission = TpcSoftwareMember.check_committer_permission?(sandbox_report.tpc_software_sig_id, current_user)
          #   end
          when TpcSoftwareCommentState::Member_Type_Sig_Lead
            permission = TpcSoftwareMember.check_sig_lead_permission?(current_user)
          when TpcSoftwareCommentState::Member_Type_Legal
            permission = TpcSoftwareMember.check_legal_permission?(current_user)
          when TpcSoftwareCommentState::Member_Type_Compliance
            permission = TpcSoftwareMember.check_compliance_permission?(current_user)
          when TpcSoftwareCommentState::Member_Type_QA
            permission = TpcSoftwareMember.check_qa_permission?(current_user)
          when TpcSoftwareCommentState::Member_Type_Community_Collaboration_WG
            permission = TpcSoftwareMember.check_wg_permission?(current_user)
          end
          raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless permission
        end


        ActiveRecord::Base.transaction do
          comment_state = TpcSoftwareCommentState.find_or_initialize_by(
            tpc_software_id: sandbox.id,
            tpc_software_type: TpcSoftwareCommentState::Type_Sandbox,
            metric_name: TpcSoftwareCommentState::Metric_Name_Sandbox,
            member_type: member_type,
            user_id: current_user.id
          )
          if state == TpcSoftwareCommentState::State_Cancel
            comment_state.destroy
          else
            comment_state.update!(
              {
                tpc_software_id: sandbox.id,
                tpc_software_type: TpcSoftwareCommentState::Type_Sandbox,
                user_id: current_user.id,
                subject_id: sandbox.subject_id,
                metric_name: TpcSoftwareCommentState::Metric_Name_Sandbox,
                state: state,
                member_type: member_type
              }
            )
          end
          TpcSoftwareSandbox.update_state(sandbox.id)

        end
        # to_state = TpcSoftwareCommentState.get_state(sandbox.id, TpcSoftwareCommentState::Type_Sandbox, member_type)
        # send_issue_comment(to_state, member_type, sandbox.issue_url, current_user)

        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

      def send_issue_comment(to_state, member_type, issue_url, current_user)
        member_type_content = TpcSoftwareCommentState.get_member_name(member_type)
        comment_content = TpcSoftwareCommentState.get_state_name(to_state)

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
