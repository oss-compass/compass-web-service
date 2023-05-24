# frozen_string_literal: true

class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  DEFAULT_REDIRECT_URL = '/submit-your-project'
  ERROR_REDIRECT_URL = '/auth/signin'
  BIND_REDIRECT_URL = '/settings/profile'

  def callback
    auth = request.env["omniauth.auth"]
    error = nil
    if current_user.present?
      login_bind = current_user.bind_omniauth(auth)
      error = I18n.t('users.already_banned', provider: auth.provider, nickname: auth.info.nickname) if login_bind.is_a?(User)
      default_url = BIND_REDIRECT_URL
    else
      user = User.from_omniauth(auth)
      sign_in(user)
      token = request.env['warden-jwt_auth.token']
      cookies['auth.token'] = { value: token, expires: 1.day.from_now }
      default_url = DEFAULT_REDIRECT_URL
    end
    redirect_to url_for(redirect_url(error: error, default_url: default_url))
  end

  def failure_message
    exception = request.respond_to?(:get_header) ? request.get_header("omniauth.error") : request.env["omniauth.error"]
    error = exception.error_reason if exception.respond_to?(:error_reason)
    error ||= exception.error if exception.respond_to?(:error)
    error ||= begin
                type = (request.respond_to?(:get_header) ? request.get_header("omniauth.error.type") : request.env["omniauth.error.type"]).to_s
                (exception.respond_to?(:message) && exception.message != type) ? "#{type}: #{exception.message}" : type
              end
    error.to_s.humanize if error
  end

  def failure
    message = I18n.t('users.login_failed', reason: failure_message)
    redirect_to url_for(redirect_url(error: message, default_url: ERROR_REDIRECT_URL, skip_cookies: true))
  end

  def redirect_url(error: nil, default_url: nil, skip_cookies: false)
    url = cookies['auth.callback-url'].presence || default_url
    url = default_url if skip_cookies
    if error.present?
      uri = Addressable::URI.parse(url)
      uri.query_values = uri.query_values.to_h.merge({ error: })
      url = uri.to_s
    end
    url
  end
end
