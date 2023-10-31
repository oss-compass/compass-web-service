require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CompassWebService
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Set Redis as the back-end for the cache.
    config.cache_store = :redis_cache_store, {
      url: ENV.fetch('REDIS_URL') { 'redis://redis:6379/1' },
      connect_timeout:    30,  # Defaults to 20 seconds
      read_timeout:       2, # Defaults to 1 second
      write_timeout:      2, # Defaults to 1 second
      reconnect_attempts: 2,   # Defaults to 0
      namespace: "#{ENV['DEFAULT_HOST']}:cache"
    }

    config.session_store :redis_session_store,
                         key: 'session',
                         redis: {
                           expire_after: 1.day, # cookie expiration
                           ttl: 1.day, # Redis expiration, defaults to 'expire_after'
                           key_prefix: "#{ENV['DEFAULT_HOST']}:session:",
                           url: ENV.fetch('REDIS_URL') { 'redis://redis:6379/1' },
                         }

    # Set Sneakers as the back-end for Active Job.
    config.active_job.queue_adapter = :sneakers

    # Mount Action Cable outside the main process or domain.
    config.action_cable.mount_path = nil
    config.action_cable.url = ENV.fetch('ACTION_CABLE_FRONTEND_URL') { 'ws://localhost:28080' }

    # Only allow connections to Action Cable from these domains.
    origins = ENV.fetch('ACTION_CABLE_ALLOWED_REQUEST_ORIGINS') { "http:\/\/localhost*" }.split(',')
    origins.map! { |url| /#{url}/ }
    config.action_cable.allowed_request_origins = origins

    default_host = URI.parse(ENV['DEFAULT_HOST'])
    config.action_mailer.default_url_options = { host: default_host.host, protocol: default_host.scheme }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV['MAIL_HOST'],
      port: ENV['MAIL_PORT'],
      authentication: ENV["MAIL_AUTH"]&.to_sym || :login,
      ssl: ENV['MAIL_SSL'] == 'true',
      user_name: ENV['MAIL_USER'],
      password: ENV['MAIL_PASSWORD'],
      enable_starttls_auto: ENV['MAIL_SECURE'] == 'true',
      open_timeout: ENV['MAIL_TIMEOUT']&.to_i || 15,
      read_timeout: ENV['MAIL_TIMEOUT']&.to_i || 15
    }

    config.i18n.raise_on_missing_translations = false
    config.i18n.available_locales = %i[en zh-CN]
    config.i18n.default_locale = :en
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*', '*.{rb,yml}')]

    # ActiveStorageSupport
    config.active_storage.routes_prefix = '/files'
    config.active_storage.draw_routes = true
    config.active_storage.resolve_model_to_route = :rails_storage_proxy

    # https://edgeguides.rubyonrails.org/configuring.html#config-active-record-encryption-hash-digest-class
    config.active_record.encryption.hash_digest_class = OpenSSL::Digest::SHA256
    config.active_record.encryption.support_sha1_for_non_deterministic_encryption = true

    # config.middleware.insert(0, Rack::ReverseProxy) do
    #   reverse_proxy_options preserve_host: true, timeout: 24 * 60 * 1000
    #   reverse_proxy '/analyze', 'http://localhost:5000/'
    # end
  end
end
