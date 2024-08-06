# frozen_string_literal: true

module Mutations
  module Tpc
    class AcceptTpcSoftwareGraduation < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :graduation_id, Integer, required: true
      argument :state, Integer, required: true, description: 'reject: -1, cancel: 0, accept: 1', default_value: '1'
      argument :member_type, Integer, required: true, description: 'committer: 0, sig lead: 1, legal: 2, compliance: 3', default_value: '0'


      def resolve(graduation_id: nil, state: 1, member_type: 0)

        current_user = context[:current_user]
        validate_tpc!(current_user)

        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') unless TpcSoftwareCommentState::States.include?(state)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') unless TpcSoftwareCommentState::Member_Types.include?(member_type)

        graduation = TpcSoftwareGraduation.find_by(id: graduation_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if graduation.nil?

        if state == TpcSoftwareCommentState::State_Accept
          review_permission = TpcSoftwareGraduation.get_review_permission(graduation, member_type)
          raise GraphQL::ExecutionError.new I18n.t('tpc.software_report_metric_not_clarified') unless review_permission
        end

        if state != TpcSoftwareCommentState::State_Cancel
          case member_type
          when TpcSoftwareCommentState::Member_Type_Committer
            graduation_report_list = TpcSoftwareGraduationReport.where("id IN (?)", JSON.parse(graduation.tpc_software_graduation_report_ids))

            committer_permission_list = graduation_report_list.map do |graduation_report|
              TpcSoftwareMember.check_committer_permission?(graduation_report.tpc_software_sig_id, current_user)
            end
            permission = committer_permission_list.include?(true)
          when TpcSoftwareCommentState::Member_Type_Sig_Lead
            permission = TpcSoftwareMember.check_sig_lead_permission?(current_user)
          when TpcSoftwareCommentState::Member_Type_Legal
            permission = TpcSoftwareMember.check_legal_permission?(current_user)
          when TpcSoftwareCommentState::Member_Type_Compliance
            permission = TpcSoftwareMember.check_compliance_permission?(current_user)
          end
          raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless permission
        end

        ActiveRecord::Base.transaction do
          comment_state = TpcSoftwareCommentState.find_or_initialize_by(
            tpc_software_id: graduation.id,
            tpc_software_type: TpcSoftwareCommentState::Type_Graduation,
            metric_name: TpcSoftwareCommentState::Metric_Name_Graduation,
            user_id: current_user.id)
          if state == TpcSoftwareCommentState::State_Cancel
            raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless comment_state.user_id == current_user.id
            comment_state.destroy
          else
            comment_state.update!(
              {
                tpc_software_id: graduation.id,
                tpc_software_type: TpcSoftwareCommentState::Type_Graduation,
                user_id: current_user.id,
                subject_id: graduation.subject_id,
                metric_name: TpcSoftwareCommentState::Metric_Name_Graduation,
                state: state,
                member_type: member_type
              }
            )
          end
        end
        to_state = TpcSoftwareCommentState.get_state(graduation.id, TpcSoftwareCommentState::Type_Graduation, member_type)
        send_issue_comment(to_state, member_type, graduation.issue_url, current_user)


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
