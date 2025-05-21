# frozen_string_literal: true
module Openapi
  module SharedParams
    module RateLimiter
      def self.check_token!(token, limit: 5000, period: 3600)
        key = "rate_limit:token:#{token}:#{Time.now.to_i / period}"

        count = Rails.cache.fetch(key, expires_in: period) { 0 }
        count += 1
        Rails.cache.write(key, count, expires_in: period)

        if count > limit
          throw :error, status: 429, message: "请求过于频繁，每小时最多允许 #{limit} 次"
        end
      end
    end
  end
end
