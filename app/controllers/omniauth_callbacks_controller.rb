# frozen_string_literal: true

class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  DEFAULT_REDIRECT_URL = '/submit-your-project'
  ERROR_REDIRECT_URL = '/auth/signin'
  BIND_REDIRECT_URL = '/settings/profile'

  def wechat_auth
    if params[:state].present? || !is_wechat_browser? \
      || session['openid'].present? || session[:user_id].present?
      return redirect_to url_for(redirect_url(default_url: DEFAULT_REDIRECT_URL))

    end
    redirect_url = users_auth_wechat_callback_url(redirect_uri: OmniauthCallbacksController::BIND_REDIRECT_URL, user_token: params[:user_token])
    state = SecureRandom.hex(24)
    session["omniauth.state"] = state
    sns_url = $wechat_client.authorize_url(redirect_url, ENV['WECHAT_SCOPE'], state)
    redirect_to(sns_url, allow_other_host: true)
  end

  def wechat_callback
    return redirect_to url_for(redirect_url(default_url: DEFAULT_REDIRECT_URL)) if params[:user_token].blank?
    error = nil
    default_url = BIND_REDIRECT_URL
    begin
      raise 'CSRF detected' if params[:state].to_s.empty? || params[:state] != session.delete("omniauth.state")

      payload = Warden::JWTAuth::TokenDecoder.new.call(params[:user_token])
      user = Warden::JWTAuth::PayloadUserHelper.find_user(payload)
      raise 'User not found' if user.blank?
      sign_in(user)
      token = request.env['warden-jwt_auth.token']
      cookies['auth.token'] = { value: token, expires: 1.day.from_now }

      sns_info = $wechat_client.get_oauth_access_token(params[:code])
      if sns_info.result['errcode'] != '40029'
        session[:openid] = sns_info.result['openid']
        auth = OmniAuth::AuthHash.new({
                                        provider: 'wechat',
                                        uid: sns_info.result['openid'],
                                        info: {
                                          name: sns_info.result['openid']
                                        },
                                        credentials: {
                                          token: sns_info.result['access_token'],
                                          refresh_token: sns_info.result['refresh_token'],
                                          expires_at: Time.now.to_i + sns_info.result['expires_in'],
                                          expires: true
                                        },
                                        extra: {
                                          raw_info: sns_info.result
                                        },
                                        scope: ENV['WECHAT_SCOPE']
                                      })

        user.bind_omniauth(auth)
      else
        raise sns_info.result['errmsg']
      end
    rescue => e
      Rails.logger.error "Wechat auth error: #{e.message}"
      error = e.message
    end
    redirect_to url_for(redirect_url(error: error, default_url: default_url))
  end

  def callback
    auth = request.env["omniauth.auth"]
    error = nil
    if current_user.present?
      login_bind = current_user.bind_omniauth(auth)
      error = I18n.t('users.already_banned', provider: auth.provider, nickname: auth.info.nickname) if login_bind.is_a?(User)
      default_url = BIND_REDIRECT_URL
    else
      if auth.provider.to_sym.in?(LoginBind::LOGIN_PROVIDER)
        user = User.from_omniauth(auth)
        sign_in(user)
        token = request.env['warden-jwt_auth.token']
        cookies['auth.token'] = { value: token, expires: 1.day.from_now }
        default_url = DEFAULT_REDIRECT_URL
      else
        default_url = ERROR_REDIRECT_URL
        error = I18n.t('users.provider_not_supported', provider: auth.provider)
      end
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
    default_host = Addressable::URI.parse(ENV['DEFAULT_HOST'])
    url = cookies['auth.callback-url'].presence || default_url
    url = default_url if skip_cookies
    uri = Addressable::URI.parse(url)
    uri.scheme = 'http'
    uri.host = default_host.host
    if error.present?
      uri.query_values = uri.query_values.to_h.merge({ error: error, ts: (Time.now.to_f * 1000).to_i })
    end
    uri.to_s
  end

  private

  def is_wechat_browser?
    request.user_agent =~ /MicroMessenger/i
  end
end
