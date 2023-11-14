# frozen_string_literal: true

module Mutations
  class SendEmailVerify < BaseMutation
    field :status, String, null: false

    def resolve
      current_user = context[:current_user]

      login_required!(current_user)

      raise GraphQL::ExecutionError.new I18n.t('users.email_verified') if current_user.email_verified?

      current_user.send_email_verification

      full_messages = current_user.errors.full_messages
      raise GraphQL::ExecutionError.new full_messages.first if full_messages.present?

      OpenStruct.new({ status: true, message: '' })
    rescue => ex
      OpenStruct.new({ status: false, message: ex.message })
    end
  end
end
