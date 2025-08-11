# frozen_string_literal: true
module Openapi
  module SharedParams

    module RestapiHelpers

      def save_tracking_api!
        path = request.path
        token = params[:access_token]
        data = {
          token: token,
          api_path: path,
          domain: request.env['HTTP_HOST'],
          ip: request.ip
        }

        host = request.env['HTTP_HOST']
        primary_domains = ENV.fetch('PRIMARY_DOMAINS', '').split(',')

        if primary_domains.include?(host)
          save_locally!(data)

        else
          save_remotely!(data)
        end
      end

      def save_locally!(data)
        token = data[:token]
        user_token = AccessToken.find_by(token: token)
        user_id = user_token[:user_id]
        save_data = TrackingRestapi.new(
          api_path: data[:api_path],
          domain: data[:domain],
          user_id: user_id,
          ip: data[:ip]
        )
        save_data.save
      end

      def save_remotely!(data)
        save_url = ENV.fetch('REMOTE_SAVE_URL')
        retries = 2
        wait_time = 1
        begin
          Faraday.post(
            save_url,
            { payload: data }.to_json,
            'Content-Type' => 'application/json'
          )
        rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
          retries -= 1
          if retries > 0
            sleep(wait_time)
            retry
          else
            error!("保存失败: #{e.message}", 503)
          end
        end
      end
    end
  end
end
