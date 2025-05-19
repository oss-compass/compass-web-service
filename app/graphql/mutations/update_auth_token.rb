module Mutations
  class UpdateAuthToken < BaseMutation
    field :status, Boolean, null: false

    argument :id, Integer, required: true, description: 'id'
    argument :name, String, required: true, description: 'token name'
    argument :expires_at, GraphQL::Types::ISO8601DateTime, required: true, description: '过期时间（ISO8601格式）'

    def resolve(id:nil,name: nil, expires_at: nil)
      current_user = context[:current_user]

      login_required!(current_user)

      token = current_user.access_tokens.find_by(id: id)
      raise GraphQL::ExecutionError, "Token不存在或无权限修改" unless token

      status = token.update(name: name, expires_at: expires_at)

      { status: status }
    end
  end
end
