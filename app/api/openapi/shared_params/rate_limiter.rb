# frozen_string_literal: true
module Openapi
  module SharedParams
    module RateLimiter
      def self.check_token!(token, limit: 5000, period: 3600)

        user = verify_token_is_admin!(token)
        return if user&.role_level.to_i > 3

        key = "rate_limit:token:#{token}:#{Time.now.to_i / period}"

        count = Rails.cache.fetch(key, expires_in: period) { 0 }
        count += 1
        Rails.cache.write(key, count, expires_in: period)

        if count > limit
          throw :error, status: 429, message: "请求过于频繁，每小时最多允许 #{limit} 次"
        end
      end

      def self.verify_token_is_admin!(token)

        verify_url = ENV.fetch('REMOTE_VERIFY_URL')
        retries = 3
        wait_time = 1
        begin
          response = Faraday.post(
            verify_url,
            { token: token  }.to_json,
            'Content-Type' => 'application/json'
          )

          data = JSON.parse(response.body) rescue {}

          if response.status == 201 && data['valid']
            current_user = User.find_by(id: data['user_id'])
          else
            error!('token校验失败,无效或过期的token', 401)
          end

        rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
          retries -= 1
          if retries > 0
            sleep(wait_time)
            retry
          else
            error!("token 校验失败: #{e.message}", 503)
          end
        end

        current_user
      end

    end
  end
end
