module Mutations
  class DeleteAuthToken < BaseMutation
    field :status, Boolean, null: false
    argument :id, Integer, required: true, description: 'token id'

    def resolve(id: nil)
      current_user = context[:current_user]

      login_required!(current_user)

      token = current_user.access_tokens.find_by(id: id)

      status = false
      if token
        token.destroy
        status = true
      else
        raise GraphQL::ExecutionError.new("Token 不存在或没有权限删除")
      end

      { status: status }
    end
  end
end
