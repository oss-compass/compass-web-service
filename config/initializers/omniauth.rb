Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'],
           client_options: { connection_opts: { request: { timeout: 10 }, proxy: ENV['PROXY'] } },
           scope: ENV['GITHUB_SCOPE']

  provider :gitee, ENV['GITEE_CLIENT_ID'], ENV['GITEE_CLIENT_SECRET'],
           client_options: { connection_opts: { request: { timeout: 10 } } },
           scope: ENV['GITEE_SCOPE']

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
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
