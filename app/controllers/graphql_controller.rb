class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    context = {
      current_user: current_user,
      sign_out: method(:sign_out),
      cookies: cookies
    }

    t = Prorate::Throttle.new(
      name: "global-api-limit",
      limit: 1000,
      period: 1.hour,
      block_for: 1.hour,
      redis: throttle_redis,
      logger: Rails.logger
    )

    real_ip =
      case request.host
      when 'compass.gitee.com'
        request.env['HTTP_X_FORWARDED_FOR']&.split(',')&.first
      else
        request.remote_ip
      end

    t << real_ip

    t.throttle! if !current_user || (real_ip && !safelist_ip(real_ip))

    result = CompassWebServiceSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue Prorate::Throttled => e
    logger.warn("blocking #{request.remote_ip} Retry-After #{e.retry_in_seconds}")
    response.set_header('Retry-After', e.retry_in_seconds.to_s)
    render json: { errors: [{ message: e.message, retry_fater: e.retry_in_seconds }], data: {} }, status: 429
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  def throttle_redis
    @throttle_redis ||= Redis.new(url: ENV.fetch('REDIS_URL') { 'redis://redis:6379/1' })
  end

  def safelist_ip(target_ip)
    Common::SAFELIST_IPS.any? do |safe_ip|
      IPAddr.new(safe_ip).include?(IPAddr.new(target_ip))
    end
  end

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end

  def sign_out(user)
    scope = Devise::Mapping.find_scope!(user)
    warden.logout(scope)
    token = request.cookies['auth.token']
    Rails.logger.info(token) ## logging token for temporary debug
    if token.present?
      payload = Warden::JWTAuth::TokenDecoder.new.call(token)
      User.revoke_jwt(payload, user)
      cookies.delete('auth.token')
    end
  end
end
