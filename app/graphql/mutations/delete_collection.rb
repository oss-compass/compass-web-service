module Mutations
  class DeleteCollection < BaseMutation
    include Common
    graphql_name 'DeleteCollection'

    field :status, String, null: false

    argument :id, Integer, required: true, description: 'collection id'
    argument :token, String, required: true, description: 'admin token'

    def resolve(id:, token:)
      if token != ADMIN_WEB_TOKEN
        return OpenStruct.new(result.merge({message: I18n.t('admin.invalid_token')}))
      end
      collection = Collection.find(id)
      collection.destroy!
      OpenStruct.new({status: true, message: I18n.t('collection.delete_success')})
    rescue => ex
      OpenStruct.new({status: false, message: I18n.t('collection.delete_failed', reason: ex.message)})
    end
  end
end
