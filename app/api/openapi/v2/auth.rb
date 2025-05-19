# frozen_string_literal: true

module Openapi
  module V2
    class Auth < Grape::API
      version 'v2', using: :path
      prefix :api
      format :json

      resource :auth do
        desc '校验token', tags: ['Auth'], hidden: true
        params do
          requires :token, type: String, desc: 'access_token'
        end
        post :verify_token do
          token = params[:token]
          error!({ error: 'token 不能为空' }, 400) if token.blank?

          access_token = AccessToken.active.find_by(token: token)

          if access_token
            {
              user_id: access_token.user_id,
              valid: true,
              expires_at: access_token.expires_at
            }
          else
            error!({ valid: false, error: '无效或过期的 token' }, 401)
          end
        end
      end
    end
  end
end
