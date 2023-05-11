# frozen_string_literal: true

module Mutations
  class UserUnbind< BaseMutation
    field :status, String, null: false
    argument :provider, String, required: true, description: 'provider name'

    def resolve(provider:)
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      current_user.login_binds.where(provider: provider).destroy_all

      OpenStruct.new({ status: true, message: '' })
    rescue => ex
      OpenStruct.new({ status: false, message: ex.message })
    end
  end
end
