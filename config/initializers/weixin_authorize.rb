namespace = "weixin_authorize"
redis = Redis.new(url: ENV.fetch('REDIS_URL') { 'redis://redis:6379/1' })

redis = Redis::Namespace.new("#{namespace}", :redis => redis)

WeixinAuthorize.configure do |config|
  config.redis = redis
  config.rest_client_options = { timeout: 15, open_timeout: 15, verify_ssl: true }
end
$wechat_client ||= WeixinAuthorize::Client.new(ENV["WECHAT_CLIENT_ID"], ENV["WECHAT_CLIENT_SECRET"])
