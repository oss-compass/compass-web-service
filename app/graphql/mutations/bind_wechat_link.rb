# frozen_string_literal: true

module Mutations
  class BindWechatLink < BaseMutation
    field :url, String, null: false

    def resolve
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      {
        url: "#{ENV['DEFAULT_HOST']}/users/auth/wechat?user_token=#{context[:cookies]['auth.token']}"
      }
    end
  end
end
