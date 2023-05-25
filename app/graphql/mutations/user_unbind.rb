# frozen_string_literal: true

module Mutations
  class UserUnbind < BaseMutation
    field :status, String, null: false
    argument :provider, String, required: true, description: 'provider name'

    def resolve(provider:)
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      providers = current_user.login_binds.where(provider: [:gitee, :github]).distinct.pluck(:provider)
      raise GraphQL::ExecutionError.new I18n.t('users.keep_one_login_bind') if (providers - [provider]).blank?

      if provider == 'wechat'
        login_bind = current_user.login_binds.find_by(provider: provider)
        uid = login_bind.uid
        login_bind.destroy
        response_data = {
          keyword1: { value: "#{current_user.name} (解绑成功)" },
          keyword2: { value: Time.current.in_time_zone("Beijing").strftime("%Y-%m-%d %H:%M:%S") }
        }
        $wechat_client.send_template_msg(uid, ENV['NOTIFICATION_WECHAT_ACCOUNT_BIND_TEMPLATE_ID'], '', '', response_data)
      else
        current_user.login_binds.where(provider: provider).destroy_all
      end

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
