# frozen_string_literal: true

module Mutations
  class ModifyUser < BaseMutation
    field :status, String, null: false

    argument :name, String, required: true, description: 'user name'
    argument :email, String, required: true, description: 'user email'
    argument :language, String, required: false, description: 'user language'

    def resolve(name:, email:, language: nil)
      current_user = context[:current_user]

      login_required!(current_user)

      update_attrs = { name: name, email: email }
      update_attrs[:language] = language if language.present?
      current_user.update!(update_attrs)

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
