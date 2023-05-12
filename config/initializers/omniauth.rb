Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'],
           client_options: { connection_opts: { request: { timeout: 10 }, proxy: ENV['PROXY'] } },
           scope: ENV['GITHUB_SCOPE']

  provider :gitee, ENV['GITEE_CLIENT_ID'], ENV['GITEE_CLIENT_SECRET'],
           client_options: { connection_opts: { request: { timeout: 10 } } },
           scope: ENV['GITEE_SCOPE']
end
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
