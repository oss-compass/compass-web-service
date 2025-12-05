# 加载自定义 GitCode OmniAuth Strategy
# lib/omniauth 已从 autoload 中排除，需要手动加载
gitcode_strategy_path = Rails.root.join('lib/omniauth/strategies/gitcode.rb')
require gitcode_strategy_path.to_s if File.exist?(gitcode_strategy_path)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'],
           client_options: { connection_opts: { request: { timeout: 10 } } },
           scope: ENV['GITHUB_SCOPE'],
           provider_ignores_state: true

  provider :gitee, ENV['GITEE_CLIENT_ID'], ENV['GITEE_CLIENT_SECRET'],
           client_options: { connection_opts: { request: { timeout: 10 } } },
           scope: ENV['GITEE_SCOPE']

  provider :gitcode, ENV['GITCODE_CLIENT_ID'], ENV['GITCODE_CLIENT_SECRET'],
           client_options: { 
             connection_opts: { request: { timeout: 10 } },
             site: 'https://gitcode.com',
             authorize_url: 'https://gitcode.com/oauth/authorize',
             token_url: 'https://gitcode.com/oauth/token'
           },
           scope: ENV['GITCODE_SCOPE'] || 'read_user',
           callback_url: "#{ENV['DEFAULT_HOST']}/users/auth/gitcode/callback",
           provider_ignores_state: true

  provider :openid_connect, {
    name: :slack,
    issuer: 'https://slack.com',
    scope: ENV['SLACK_SCOPE'].split(' ').map(&:to_sym),
    response_type: :code,
    discovery: true,
    uid_field: 'sub',
    client_jwk_signing_key: ENV['SLACK_CLIENT_JWK_SIGNING_KEY'],
    response_mode: :query,
    client_options: {
      port: 443,
      scheme: 'https',
      host: 'slack.com',
      authorization_endpoint: '/openid/connect/authorize',
      token_endpoint: '/api/openid.connect.token',
      userinfo_endpoint: '/api/openid.connect.userInfo',
      jwks_uri: '/openid/connect/keys',
      identifier: ENV['SLACK_CLIENT_ID'],
      secret: ENV['SLACK_CLIENT_SECRET'],
      redirect_uri: "#{ENV['DEFAULT_HOST']}/users/auth/slack/callback",
    },
    callback_path: '/users/auth/slack/callback',
  }
  # provider :wechat, ENV['WECHAT_CLIENT_ID'], ENV['WECHAT_CLIENT_SECRET'],
  #          client_options: { connection_opts: { request: { timeout: 10 } } },
  #          authorize_params: { scope: ENV['WECHAT_SCOPE'] }
end

# OmniAuth 配置
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
OmniAuth.config.full_host = ENV['DEFAULT_HOST']

# 处理 CSRF 错误的回调
# OmniAuth.config.on_failure = Proc.new { |env|
#   message_key = env['omniauth.error.type']
#   error_message = env['omniauth.error']
  
#   Rails.logger.error "OmniAuth failure: #{message_key} - #{error_message}"
#   Rails.logger.error "Session: #{env['rack.session'].inspect}"
#   Rails.logger.error "Request params: #{env['rack.request.query_hash'].inspect}"
  
#   OmniAuth::FailureEndpoint.new(env).redirect_to_failure
# }
