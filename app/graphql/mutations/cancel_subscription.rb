# frozen_string_literal: true

module Mutations
  class CancelSubscription < BaseMutation
    field :status, String, null: false
    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: true, description: 'repo or project level(repo/community)'

    def resolve(label: nil, level: nil)
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      subscription = current_user.subscriptions.find_by(subject: Subject.find_by(label: label))
      raise GraphQL::ExecutionError.new I18n.t('users.subscription_not_exist') if subscription.blank?

      subscription.destroy
      { status: true }
    end
  end
end
