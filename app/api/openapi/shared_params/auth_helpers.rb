# frozen_string_literal: true
module Openapi
  module SharedParams

    module AuthHelpers
      def current_user
        return @current_user if defined?(@current_user)

        token_str = params[:access_token]
        token = AccessToken.active.find_by(token: token_str)
        @current_user = token&.user
      end

      def require_token!
        token = params[:access_token]
        error!('token 不能为空', 401) if token.blank?

        host = request.env['HTTP_HOST']
        primary_domains = ENV.fetch('PRIMARY_DOMAINS', '').split(',')

        if primary_domains.include?(host)
          verify_token_locally!(token)
        else
          verify_token_remotely!(token)
        end
      end

      def verify_token_locally!(token)
        access_token = AccessToken.active.find_by(token: token)
        error!('无效或过期的token', 401) unless access_token
        @current_user = access_token.user
      end

      def verify_token_remotely!(token)

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
            @current_user = User.find_by(id: data['user_id'])
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
      end
    end
  end
end
