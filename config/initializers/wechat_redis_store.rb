# frozen_string_literal: true

module Wechat
  def self.redis
    @redis ||= Redis.new(url: ENV.fetch('REDIS_URL') { 'redis://redis:6379/1' })
  end

  module Token
    class AccessTokenBase
      def read_token
        JSON.parse(Wechat.redis.get(redis_key)) || {}
      end

      def write_token(token_hash)
        Wechat.redis.set redis_key, token_hash.to_json
      end

      private

      def redis_key
        "wechat_token_#{secret}"
      end
    end
  end

  module Ticket
    class JsapiBase
      def read_ticket
        JSON.parse(Wechat.redis.get(redis_key)) || {}
      end

      def write_ticket(ticket_hash)
        Wechat.redis.set redis_key, ticket_hash.to_json
      end

      private

      def redis_key
        "wechat_ticket_#{access_token.secret}"
      end
    end
  end
end
