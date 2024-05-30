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
