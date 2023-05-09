# frozen_string_literal: true

class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # 默认重定向 URL
  DEFAULT_REDIRECT_URL = '/auth/signin'

  def callback
    auth = request.env["omniauth.auth"]
    user = User.from_omniauth(auth)
    sign_in(user)
    token = request.env['warden-jwt_auth.token']
    cookies['auth.token'] = { value: token, expires: 1.day.from_now }
    redirect_to url_for(redirect_url)
  end

  def failure_message
    exception = request.respond_to?(:get_header) ? request.get_header("omniauth.error") : request.env["omniauth.error"]
    error = exception.error_reason if exception.respond_to?(:error_reason)
    error ||= exception.error if exception.respond_to?(:error)
    error ||= begin
                type = (request.respond_to?(:get_header) ? request.get_header("omniauth.error.type") : request.env["omniauth.error.type"]).to_s
                exception.respond_to?(:message) ? "#{type}: #{exception.message}" : type
              end
    error.to_s.humanize if error
  end

  def failure
    message = I18n.t('users.login_failed', reason: failure_message)
    redirect_to url_for(redirect_url(message))
  end

  def redirect_url(error = nil)
    url = cookies['auth.callback-url'].presence || DEFAULT_REDIRECT_URL
    if error.present?
      uri = Addressable::URI.parse(url)
      uri.query_values = uri.query_values.to_h.merge({ error: })
      url = uri.to_s
    end
    url
  end
end
