module Mutations
  class DeleteKeyword < BaseMutation
    include Common
    graphql_name 'DeleteKeyword'

    field :status, String, null: false

    argument :id, Integer, required: true, description: 'keyword id'
    argument :token, String, required: true, description: 'admin token'

    def resolve(id:, token:)
      if token != ADMIN_WEB_TOKEN
        return OpenStruct.new(result.merge({message: I18n.t('admin.invalid_token')}))
      end
      keyword = Keyword.find(id)
      keyword.destroy!
      OpenStruct.new({status: true, message: I18n.t('keyword.delete_success')})
    rescue => ex
      OpenStruct.new({status: false, message: I18n.t('keyword.delete_failed', reason: ex.message)})
    end
  end
end
