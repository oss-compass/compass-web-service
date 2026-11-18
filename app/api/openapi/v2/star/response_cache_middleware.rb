# frozen_string_literal: true

module Openapi
  module V2
    module Star
      # Star V2 接口整响应缓存（Redis）：
      # - key = 接口路径 + 规范化参数（project_urls 排序，参数键排序）
      # - 快照/指标/头像类接口缓存 1 小时，活动计数类缓存 15 分钟
      # - 仅缓存 201 响应；STAR_V2_CACHE_DISABLED=1 可关闭
      class ResponseCacheMiddleware
        SHORT_TTL = ENV.fetch('STAR_V2_CACHE_TTL', 15.minutes).to_i
        LONG_TTL = ENV.fetch('STAR_V2_CACHE_LONG_TTL', 1.hour).to_i
        LONG_TTL_ENDPOINTS = %w[
          fork_count fork_count_period star_count star_count_period
          oss_compass_index oss_compass_index_period user_avatar
        ].freeze

        def initialize(app)
          @app = app
        end

        def call(env)
          return @app.call(env) if disabled? || env['REQUEST_METHOD'] != 'POST'

          path = env['PATH_INFO'].to_s
          return @app.call(env) unless path.include?('/star_v2_project_server/')

          body = read_body(env)
          key = cache_key(path, body)

          cached = Rails.cache.read(key)
          if cached
            return [201, { 'Content-Type' => 'application/json' }, [cached]]
          end

          status, headers, response = @app.call(env)
          if status == 201
            payload = +''
            response.each { |part| payload << part.to_s }
            Rails.cache.write(key, payload, expires_in: ttl_for(path))
          end
          [status, headers, response]
        end

        private

        def disabled?
          @disabled ||= ENV['STAR_V2_CACHE_DISABLED'].present?
        end

        def read_body(env)
          body = env['rack.input'].read
          env['rack.input'].rewind
          body
        end

        # project_urls 排序 + 参数键排序，等价参数命中同一缓存
        def cache_key(path, raw_body)
          parsed = begin
            JSON.parse(raw_body)
          rescue StandardError
            {}
          end
          if parsed['project_urls'].is_a?(Array)
            parsed['project_urls'] = parsed['project_urls'].map(&:to_s).sort
          end
          "star_v2:#{Digest::MD5.hexdigest([path, parsed.sort.to_json].join('|'))}"
        end

        def ttl_for(path)
          endpoint = path.split('/').last.to_s.split('.').first
          LONG_TTL_ENDPOINTS.include?(endpoint) ? LONG_TTL : SHORT_TTL
        end
      end
    end
  end
end
