# frozen_string_literal: true

class WeChatController < ApplicationController
  def verify
    render plain: params[:echostr]
  end

  wechat_responder appid: ENV['WECHAT_CLIENT_ID'], secret: ENV['WECHAT_CLIENT_SECRET'], token: ENV['WECHAT_TOKEN']
  on :event, with: 'subscribe' do |request|
    user = LoginBind.find_by(provider: 'wechat', uid: params[:openid])&.user
    if user.present?
      message = "欢迎回来，#{user.name}"
    else
      message = "欢迎关注开源指南针，点击链接可以绑定微信订阅通知 #{ENV['WECHAT_SUBSCRIBE_LINK']}"
    end
    request.reply.text message
  end

  on :event, with: 'scan' do |request|
    response_data = scan_bind(params, request)

    if response_data.is_a?(String)
      request.reply.text response_data
    else
      $wechat_client.send_template_msg(params[:openid], ENV['NOTIFICATION_WECHAT_ACCOUNT_BIND_TEMPLATE_ID'], '', '', response_data)
    end
  end

  def scan_bind(params, request)
    cache_key = "wechat_bind:#{request[:Ticket]}"
    user_id = Rails.cache.read(cache_key)
    Rails.cache.delete(cache_key)
    return '绑定二维码已过期,请重新绑定！' if user_id.blank?

    bind_user = LoginBind.find_by(provider: 'wechat', uid: params[:openid])&.user
    return "你已经绑定 #{bind_user.name}，无需重复绑定！" if bind_user.present?

    user = User.find_by_id(user_id)
    return '绑定二维码错误,请重新绑定！' if user.blank?
    auth = OmniAuth::AuthHash.new({
                                    provider: 'wechat',
                                    uid: params[:openid],
                                    info: { name: params[:openid] },
                                    credentials: {},
                                    extra: {},
                                    scope: ENV['WECHAT_SCOPE']
                                  })

    login_bind = user.bind_omniauth(auth)
    return "该微信已经绑定 #{user.name}" if login_bind.is_a?(User)

    {
      keyword1: { value: "#{user.name} (绑定成功)" },
      keyword2: { value: Time.current.in_time_zone("Beijing").strftime("%Y-%m-%d %H:%M:%S") }
    }
  end
end

