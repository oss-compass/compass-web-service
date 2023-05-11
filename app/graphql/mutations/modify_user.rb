# frozen_string_literal: true

module Mutations
  class ModifyUser < BaseMutation
    field :status, String, null: false

    argument :name, String, required: true, description: 'user name'
    argument :email, String, required: true, description: 'user email'

    def resolve(name:, email:)
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      current_user.update!(name: name, email: email)

      OpenStruct.new({ status: true, message: '' })
    rescue => ex
      OpenStruct.new({ status: false, message: ex.message })
    end
  end
end
