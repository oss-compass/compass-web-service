# frozen_string_literal: true

module Mutations
  class ModifyUser < BaseMutation
    field :status, String, null: false

    argument :name, String, required: true, description: 'user name'
    argument :email, String, required: true, description: 'user email'
    argument :language, String, required: false, description: 'user language'

    def resolve(name:, email:, language:)
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      update_attrs = { name: name, email: email }
      update_attrs[:language] = language if language.present?
      current_user.update!(update_attrs)

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
