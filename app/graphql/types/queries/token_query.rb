# frozen_string_literal: true

module Types
  module Queries
    class TokenQuery  < BaseQuery

      type [Types::TokenType], null: true
      description 'Get list of token'

      def resolve()

        login_required!(context[:current_user])

        current_user = context[:current_user]
        # 根据user_id  查询
        current_user.access_tokens.order(created_at: :desc)
      end
    end
  end
end
