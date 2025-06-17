module Types
  class MutationType < Types::BaseObject
    field :create_repo_task, mutation: Mutations::CreateRepoTask, description: 'Submit a repository analysis task'
    field :create_project_task, mutation: Mutations::CreateProjectTask, description: 'Submit a community analysis task'
    field :sign_out, Boolean, description: 'Sign out'
    field :destroy_user, Boolean, description: 'Destroy user'
    field :modify_user, mutation: Mutations::ModifyUser, description: 'Modify user'
    field :modify_user_orgs, mutation: Mutations::ModifyUserOrgs, description: 'Modify user organizations'
    field :user_unbind, mutation: Mutations::UserUnbind, description: 'User unbind'
    field :send_email_verify, mutation: Mutations::SendEmailVerify, description: 'Send email verify'
    field :bind_wechat_link, mutation: Mutations::BindWechatLink, description: 'Bind wechat link'
    field :create_subscription, mutation: Mutations::CreateSubscription, description: 'Create subscription'
    field :cancel_subscription, mutation: Mutations::CancelSubscription, description: 'Cancel subscription'

    field :manage_user_orgs, mutation: Mutations::ManageUserOrgs, description: 'Manage user organizations'

    # Lab Model Management
    field :create_lab_model, mutation: Mutations::CreateLabModel, description: 'Create a Lab model'
    field :delete_lab_model, mutation: Mutations::DeleteLabModel, description: 'Delete a Lab model'
    field :update_lab_model, mutation: Mutations::UpdateLabModel, description: 'Update a Lab model'
    field :create_lab_model_version, mutation: Mutations::CreateLabModelVersion, description: 'Create a Lab model version'
    field :delete_lab_model_version, mutation: Mutations::DeleteLabModelVersion, description: 'Delete a Lab model version'
    field :update_lab_model_version, mutation: Mutations::UpdateLabModelVersion, description: 'Update a Lab model version'
    field :trigger_lab_model_version, mutation: Mutations::TriggerLabModelVersion, description: 'Trigger the analysis of a Lab model version'
    field :trigger_single_project, mutation: Mutations::TriggerSingleProject, description: 'Trigger the analysis of a Lab model version project'
    field :create_lab_model_dataset, mutation: Mutations::CreateLabModelDataset, description: 'Create a Lab model dataset'
    field :create_lab_dataset, mutation: Mutations::CreateLabDataset, description: 'Create a Lab  dataset'
    field :update_lab_model_report, mutation: Mutations::UpdateLabModelReport, description: 'Update a lab report dataset'
    field :delete_lab_model_report, mutation: Mutations::DeleteLabModelReport, description: 'Update a lab report dataset'

    field :trigger_finance_standard_project_version, mutation: Mutations::TriggerFinanceStandardProjectVersion, description: 'Trigger the analysis of a finance standard project version'

    field :send_member_invite, mutation: Mutations::SendMemberInvite, description: 'Send member invitation'
    field :cancel_member_invite, mutation: Mutations::CancelMemberInvite, description: 'Cancel a member invitation'
    field :update_member_permission, mutation: Mutations::UpdateMemberPermission, description: 'Update a member permission'
    field :delete_lab_member, mutation: Mutations::DeleteLabMember, description: 'Delete a lab member'

    field :create_lab_model_comment, mutation: Mutations::CreateLabModelComment, description: 'Create a comment for a lab model'
    field :update_lab_model_comment, mutation: Mutations::UpdateLabModelComment, description: 'Update a comment for a lab model'
    field :delete_lab_model_comment, mutation: Mutations::DeleteLabModelComment, description: 'Delete a comment for a lab model'

    field :add_repo_extension, mutation: Mutations::AddRepoExtension, description: 'add repo extension info'
    field :create_commit_feedback, mutation: Mutations::CreateCommitFeedback, description: 'Create a feedback on commit data'
    field :review_commit_feedback, mutation: Mutations::ReviewCommitFeedback, description: 'Review a feedback on commit data'
    field :modify_organization, mutation: Mutations::ModifyOrganization, description: 'Add or modify an organization'
    field :delete_organization, mutation: Mutations::DeleteOrganization, description: 'Delete an organization'

    field :create_subject_access_level, mutation: Mutations::CreateSubjectAccessLevel, description: 'Create a Subject access level'
    field :delete_subject_access_level, mutation: Mutations::DeleteSubjectAccessLevel, description: 'Delete a Subject access level'
    field :update_subject_access_level, mutation: Mutations::UpdateSubjectAccessLevel, description: 'Update a Subject access level'

    field :create_subject_sig, mutation: Mutations::CreateSubjectSig, description: 'Create a Subject sig'
    field :delete_subject_sig, mutation: Mutations::DeleteSubjectSig, description: 'Delete a Subject sig'
    field :update_subject_sig, mutation: Mutations::UpdateSubjectSig, description: 'Update a Subject sig'

    field :create_tpc_software_selection_report, mutation: Mutations::Tpc::CreateTpcSoftwareSelectionReport, description: 'Create a tpc software selection report'
    field :update_tpc_software_selection_report, mutation: Mutations::Tpc::UpdateTpcSoftwareSelectionReport, description: 'Update a tpc software selection report'
    field :trigger_tpc_software_selection_report, mutation: Mutations::Tpc::TriggerTpcSoftwareSelectionReport, description: 'Trigger a tpc software selection report'

    field :create_tpc_software_selection, mutation: Mutations::Tpc::CreateTpcSoftwareSelection, description: 'Create a tpc software selection'
    field :update_tpc_software_selection, mutation: Mutations::Tpc::UpdateTpcSoftwareSelection, description: 'Update a tpc software selection'
    field :accept_tpc_software_selection, mutation: Mutations::Tpc::AcceptTpcSoftwareSelection, description: 'Accept a tpc software selection'


    field :create_tpc_software_lectotype_report, mutation: Mutations::Tpc::CreateTpcSoftwareLectotypeReport, description: 'Create a tpc software lectotype report'
    field :update_tpc_software_lectotype_report, mutation: Mutations::Tpc::UpdateTpcSoftwareLectotypeReport, description: 'Update a tpc software lectotype report'
    field :trigger_tpc_software_lectotype_report, mutation: Mutations::Tpc::TriggerTpcSoftwareLectotypeReport, description: 'Trigger a tpc software lectotype report'

    field :create_tpc_software_lectotype, mutation: Mutations::Tpc::CreateTpcSoftwareLectotype, description: 'Create a tpc software lectotype'
    field :update_tpc_software_lectotype, mutation: Mutations::Tpc::UpdateTpcSoftwareLectotype, description: 'Update a tpc software lectotype'
    field :accept_tpc_software_lectotype, mutation: Mutations::Tpc::AcceptTpcSoftwareLectotype, description: 'Accept a tpc software lectotype'

    field :create_tpc_software_report_metric_clarification, mutation: Mutations::Tpc::CreateTpcSoftwareReportMetricClarification, description: 'Create a tpc software report metric clarification'
    field :update_tpc_software_report_metric_clarification, mutation: Mutations::Tpc::UpdateTpcSoftwareReportMetricClarification, description: 'Update a tpc software report metric clarification'
    field :delete_tpc_software_report_metric_clarification, mutation: Mutations::Tpc::DeleteTpcSoftwareReportMetricClarification, description: 'Delete a tpc software report metric clarification'
    field :accept_tpc_software_report_metric_clarification, mutation: Mutations::Tpc::AcceptTpcSoftwareReportMetricClarification, description: 'Accept a tpc software report metric clarification'

    field :create_tpc_software_selection_comment, mutation: Mutations::Tpc::CreateTpcSoftwareSelectionComment, description: 'Create a tpc software comment'
    field :update_tpc_software_selection_comment, mutation: Mutations::Tpc::UpdateTpcSoftwareSelectionComment, description: 'Update a tpc software comment'
    field :delete_tpc_software_selection_comment, mutation: Mutations::Tpc::DeleteTpcSoftwareSelectionComment, description: 'Delete a tpc software comment'

    field :create_tpc_software_graduation_report, mutation: Mutations::Tpc::CreateTpcSoftwareGraduationReport, description: 'Create a tpc software graduation report'
    field :update_tpc_software_graduation_report, mutation: Mutations::Tpc::UpdateTpcSoftwareGraduationReport, description: 'Update a tpc software graduation report'
    field :trigger_tpc_software_graduation_report, mutation: Mutations::Tpc::TriggerTpcSoftwareGraduationReport, description: 'Trigger a tpc software graduation report'

    field :create_third_software_report, mutation: Mutations::Tpc::CreateThirdSoftwareReport, description: 'Create a third software graduation report'
    field :delete_third_software_report, mutation: Mutations::Tpc::DeleteThirdSoftwareReport, description: 'Delete a third software graduation report'

    field :create_tpc_software_graduation, mutation: Mutations::Tpc::CreateTpcSoftwareGraduation, description: 'Create a tpc software graduation'
    field :update_tpc_software_graduation, mutation: Mutations::Tpc::UpdateTpcSoftwareGraduation, description: 'Update a tpc software graduation'
    field :accept_tpc_software_graduation, mutation: Mutations::Tpc::AcceptTpcSoftwareGraduation, description: 'Accept a tpc software graduation'


    field :create_auth_token, mutation: Mutations::CreateAuthToken, description: 'Create auth token'
    field :delete_auth_token, mutation: Mutations::DeleteAuthToken, description: 'Delete auth token'


    field :vote_down, mutation: Mutations::VoteDown, description: 'vote down'
    field :vote_up, mutation: Mutations::VoteUp, description: 'vote up'

    # User Cancellation
    def sign_out
      context[:sign_out].call(context[:current_user]) if context[:current_user].present?
      true
    end

    def destroy_user
      user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if user.blank?

      user.destroy
      true
    end
  end
end
