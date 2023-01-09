module Mutations
  class AppendKeywordToCollection < BaseMutation
    include Common
    graphql_name 'AppendKeywordToCollection'

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
      keyword = Keyword.find_by(id: keyword_id)
      collection = Collection.find_by(id: collection_id)

      messages << I18n.t('keyword.invalid') unless keyword.present?
      messages << I18n.t('collection.invalid') unless collection.present?

      if messages.present?
        return OpenStruct.new(result.merge({message: messages.join(',')}))
      end

      collection.keywords << keyword

      OpenStruct.new(result.merge({status: true, data: collection}))
    rescue => ex
      OpenStruct.new(
        result.merge(
          {
            status: false,
            message: I18n.t('collection.append_keyword_failed', reason: ex.message)
          }
        )
      )
    end
  end
end
