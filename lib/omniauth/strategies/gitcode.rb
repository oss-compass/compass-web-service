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

      uid { raw_info['id'].to_s }

      info do
        {
          name: raw_info['login'] || raw_info['name'],
          nickname: raw_info['name'],
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
        end
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end

