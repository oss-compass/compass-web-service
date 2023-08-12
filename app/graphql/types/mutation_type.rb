module Types
  class MutationType < Types::BaseObject
    field :create_repo_task, mutation: Mutations::CreateRepoTask, description: 'Submit a repository analysis task'
    field :create_project_task, mutation: Mutations::CreateProjectTask, description: 'Submit a community analysis task'
    field :sign_out, Boolean, description: 'Sign out'
    field :destroy_user, Boolean, description: 'Destroy user'
    field :modify_user, mutation: Mutations::ModifyUser, description: 'Modify user'
    field :user_unbind, mutation: Mutations::UserUnbind, description: 'User unbind'
    field :send_email_verify, mutation: Mutations::SendEmailVerify, description: 'Send email verify'
    field :bind_wechat_link, mutation: Mutations::BindWechatLink, description: 'Bind wechat link'
    field :create_subscription, mutation: Mutations::CreateSubscription, description: 'Create subscription'
    field :cancel_subscription, mutation: Mutations::CancelSubscription, description: 'Cancel subscription'

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
