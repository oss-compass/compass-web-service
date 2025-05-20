module Mutations
  class CreateAuthToken < BaseMutation
    field :data, Types::TokenType, null: true

    argument :name, String, required: true, description: 'token name'
    # argument :expires_at, Integer, required: true, description: 'expires time'
    argument :expires_at, GraphQL::Types::ISO8601DateTime, required: true, description: '过期时间（ISO8601格式）'

    def resolve(name: nil, expires_at: nil)
      current_user = context[:current_user]

      login_required!(current_user)

      if current_user.access_tokens.count >= 5
        raise GraphQL::ExecutionError, '最多只能创建 5 个 token，请先删除已有的 token。'
      end

      token = current_user.access_tokens.create!(
        name: name,
        expires_at: expires_at
      )

      {
        data: token
      }

    end
  end
end
