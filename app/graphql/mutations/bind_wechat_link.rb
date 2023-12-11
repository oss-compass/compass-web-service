# frozen_string_literal: true

module Mutations
  class BindWechatLink < BaseMutation
    field :expire_seconds, Integer, null: false
    field :ticket, String, null: false
    field :url, String, null: false

    def resolve
      current_user = context[:current_user]

      login_required!(current_user)

      raise(GraphQL::ExecutionError.new I18n.t('users.wechat_already_bind')) if current_user.login_binds.exists?(provider: 'wechat')

      qr_code_response = $wechat_client.create_qr_scene(current_user.id)
      ticket = qr_code_response.result['ticket']
      expire_seconds = qr_code_response.result['expire_seconds']
      Wechat.redis.set("wechat_bind:#{ticket}", current_user.id, ex: expire_seconds.seconds)
      {
        ticket: ticket,
        expire_seconds: expire_seconds,
        url: qr_code_response.result['url']
      }
    end
  end
end
