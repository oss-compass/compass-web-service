# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Gitcode < OmniAuth::Strategies::OAuth2
      option :name, 'gitcode'

      option :client_options, {
        site: 'https://gitcode.com',
        authorize_url: 'https://gitcode.com/oauth/authorize',
        token_url: 'https://gitcode.com/oauth/token'
      }

      # 确保 client_id 和 client_secret 正确传递
      option :authorize_params, {
        client_id: nil
      }

      option :token_params, {
        client_id: nil,
        client_secret: nil
      }

      uid { raw_info['id'].to_s }

      info do
        {
          name: raw_info['name'] || raw_info['login'],
          nickname: raw_info['login'],
          email: raw_info['email'],
          image: raw_info['avatar_url']
        }
      end

      extra do
        { raw_info: raw_info }
      end

      # def raw_info
      #   @raw_info ||= access_token.get('/api/v5/user').parsed
      # end

      def raw_info
        @raw_info ||= begin
          response = access_token.get('/api/v5/user')
          # 转码响应体为 UTF-8
          raw_data = response.body.force_encoding('UTF-8').scrub('?')
          JSON.parse(raw_data)
        rescue => e
          # 确保错误信息也使用正确的编码
          error_message = e.message.force_encoding('UTF-8').scrub('?')
          Rails.logger.error "GitCode API error: #{error_message}"
          raise e
        end
      end

      def callback_url
        full_host + script_name + callback_path
      end

      # 重写 build_access_token 方法，确保参数正确传递
      def build_access_token
        verifier = request.params['code']
        params = {
          'client_id' => options.client_id,
          'client_secret' => options.client_secret,
          'code' => verifier,
          'grant_type' => 'authorization_code',
          'redirect_uri' => callback_url
        }.merge(token_params.to_hash(symbolize_keys: true))

        client.auth_code.get_token(verifier, params, deep_symbolize(options.auth_token_params))
      end
    end
  end
end

