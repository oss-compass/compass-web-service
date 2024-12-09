require 'riak'

# Riak session storage for Rails, and for Rails only. Derived from
# the MemCacheStore code, simply dropping in Riak instead.
class RiakSessionStore < ActionDispatch::Session::AbstractSecureStore
  # Rails 3.1 and beyond defines the constant elsewhere
  unless defined?(ENV_SESSION_OPTIONS_KEY)
    ENV_SESSION_OPTIONS_KEY = if Rack.release.split('.').first.to_i > 1
                                Rack::RACK_SESSION_OPTIONS
                              else
                                Rack::Session::Abstract::ENV_SESSION_OPTIONS_KEY
                              end
  end

  USE_INDIFFERENT_ACCESS = defined?(ActiveSupport).freeze
  # ==== Options
  # * +:key+ - Same as with the other cookie stores, key name
  # * +:riak+ - A hash with riak-specific options
  # * +:on_riak_down:+ - Called with err, env, and SID on Errno::ECONNREFUSED
  # * +:on_session_load_error:+ - Called with err and SID on Marshal.load fail
  # * +:serializer:+ - Serializer to use on session data, default is :marshal.
  #
  # ==== Examples
  #
  #     Rails.application.config.session_store :riak_session_store,
  #       key: 'your_session_key',
  #       riak: {
  #         expire_after: 120.minutes,
  #         host: 'localhost',
  #         pb_port: 8087,
  #         bucket: 'sessions',
  #         bucket_type: 'leveled'
  #       },
  #       on_riak_down: ->(*a) { logger.error("Riak down! #{a.inspect}") },
  #       serializer: :hybrid # migrate from Marshal to JSON
  #
  def initialize(app, options = {})
    super

    @default_options[:namespace] = 'rack:session'
    options[:bucket] ||= 'sessions'
    options[:bucket_type] ||= 'default'
    @default_options.merge!(options[:riak] || {})
    init_options = options[:riak]&.reject { |k, _v| %i[expire_after key_prefix bucket bucket_type].include?(k) } || {}
    @riak = init_options[:client] || Riak::Client.new(init_options)
    @bucket = @riak.bucket_type(options[:bucket_type]).bucket(options[:bucket])
    @on_riak_down = options[:on_riak_down]
    @serializer = determine_serializer(options[:serializer])
    @on_session_load_error = options[:on_session_load_error]
    verify_handlers!
  end

  attr_accessor :on_riak_down, :on_session_load_error

  private

  attr_reader :riak, :bucket, :key, :default_options, :serializer

  # overrides method defined in rack to actually verify session existence
  # Prevents needless new sessions from being created in scenario where
  # user HAS session id, but it already expired, or is invalid for some
  # other reason, and session was accessed only for reading.
  def session_exists?(env)
    value = current_session_id(env)

    !!(
      value && !value.empty? &&
      key_exists?(value)
    )
  rescue RuntimeError => e
    on_riak_down.call(e, env, value) if on_riak_down

    true
  end

  def key_exists?(value)
    bucket.exists?(prefixed(value))
  end

  def verify_handlers!
    %w(on_riak_down on_session_load_error).each do |h|
      next unless (handler = public_send(h)) && !handler.respond_to?(:call)

      raise ArgumentError, "#{h} handler is not callable"
    end
  end

  def prefixed(sid)
    "#{default_options[:key_prefix]}#{sid}"
  end

  def session_default_values
    [generate_sid, USE_INDIFFERENT_ACCESS ? {}.with_indifferent_access : {}]
  end

  def get_session(env, sid)
    sid && (session = load_session_from_riak(sid)) ? [sid, session] : session_default_values
  rescue RuntimeError => e
    on_riak_down.call(e, env, sid) if on_riak_down
    session_default_values
  end
  alias find_session get_session

  def load_session_from_riak(sid)
    begin
      data = bucket.get(prefixed(sid))
      session_data = data ? decode(data.data) : nil
      if session_data &&
         (session_data['timestamp'].to_i + session_data['expiry'].to_i) > Time.now.to_i
        session_data['data']
      else
        destroy_session_from_sid(sid, drop: true)
      end
    rescue StandardError => e
      destroy_session_from_sid(sid, drop: true)
      on_session_load_error.call(e, sid) if on_session_load_error
      nil
    end
  end

  def decode(data)
    session = serializer.load(data)
    USE_INDIFFERENT_ACCESS ? session.with_indifferent_access : session
  end

  def set_session(env, sid, session_data, options = nil)
    expiry = get_expiry(env, options)
    session = bucket.new(prefixed(sid))
    session.data = encode({ 'timestamp' => Time.now.to_i, 'expiry' => expiry.to_i, 'data' => session_data })
    session.content_type = determine_content_type(options[:serializer])
    session.store
    sid
  rescue RuntimeError => e
    on_riak_down.call(e, env, sid) if on_riak_down
    false
  end
  alias write_session set_session

  def get_expiry(env, options)
    session_storage_options = options || env.fetch(ENV_SESSION_OPTIONS_KEY, {})
    session_storage_options[:ttl] || session_storage_options[:expire_after]
  end

  def encode(session_data)
    serializer.dump(session_data)
  end

  def destroy_session(env, sid, options)
    destroy_session_from_sid(sid, (options || {}).to_hash.merge(env: env))
  end
  alias delete_session destroy_session

  def destroy(env)
    if env['rack.request.cookie_hash'] &&
       (sid = env['rack.request.cookie_hash'][key])
      sid = Rack::Session::SessionId.new(sid)
      destroy_session_from_sid(sid, drop: true, env: env)
    end
    false
  end

  def destroy_session_from_sid(sid, options = {})
    bucket.delete(prefixed(sid))
    (options || {})[:drop] ? nil : generate_sid
  rescue RuntimeError => e
    on_riak_down.call(e, options[:env] || {}, sid) if on_riak_down
  end

  def determine_serializer(serializer)
    serializer ||= :marshal
    case serializer
    when :marshal then Marshal
    when :json    then JsonSerializer
    when :hybrid  then HybridSerializer
    else serializer
    end
  end

  def determine_content_type(serializer)
    serializer ||= :marshal
    case serializer
    when :marshal then 'application/x-ruby-marshal'
    when :json    then 'application/json'
    else 'application/x-ruby-marshal'
    end
  end

  # Uses built-in JSON library to encode/decode session
  class JsonSerializer
    def self.load(value)
      JSON.parse(value, quirks_mode: true)
    end

    def self.dump(value)
      JSON.generate(value, quirks_mode: true)
    end
  end

  # Transparently migrates existing session values from Marshal to JSON
  class HybridSerializer < JsonSerializer
    MARSHAL_SIGNATURE = "\x04\x08".freeze

    def self.load(value)
      if needs_migration?(value)
        Marshal.load(value)
      else
        super
      end
    end

    def self.needs_migration?(value)
      value.start_with?(MARSHAL_SIGNATURE)
    end
  end
end
