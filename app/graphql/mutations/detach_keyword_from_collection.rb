module Mutations
  class DetachKeywordFromCollection < BaseMutation
    include Common
    graphql_name 'DetachKeywordFromCollection'

    field :status, String, null: false
    field :data, Types::Collection::CollectionDetailType

    argument :collection_id, Integer, required: true, description: 'collection id'
    argument :keyword_id, Integer, required: true, description: 'keyword id'
    argument :token, String, required: true, description: 'admin token'

    def resolve(collection_id:, keyword_id:, token:)
      result = { status: false, data: nil, message: '' }
      if token != ADMIN_WEB_TOKEN
        return OpenStruct.new(result.merge({message: I18n.t('admin.invalid_token')}))
      end

      messages = []
      collection = Collection.find_by(id: collection_id)
      keyword_ref = collection.collection_keyword_refs.find_by(keyword_id: keyword_id)

      messages << I18n.t('collection.no_such_keyword') unless keyword_ref.present?
      messages << I18n.t('collection.invalid') unless collection.present?

      if messages.present?
        return OpenStruct.new(result.merge({message: messages.join(',')}))
      end

      keyword_ref.destroy!

      OpenStruct.new(result.merge({status: true, data: collection}))
    rescue => ex
      OpenStruct.new(
        result.merge(
          {
            status: false,
            message: I18n.t('collection.detach_keyword_failed', reason: ex.message)
          }
        )
      )
    end
  end
end
