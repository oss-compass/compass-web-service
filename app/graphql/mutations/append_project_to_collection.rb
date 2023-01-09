module Mutations
  class AppendProjectToCollection < BaseMutation
    include Common
    graphql_name 'AppendProjectToCollection'

    field :status, String, null: false
    field :data, Types::Collection::CollectionDetailType

    argument :collection_id, Integer, required: true, description: 'collection id'
    argument :label, String, required: true, description: 'repo or community label'
    argument :token, String, required: true, description: 'admin token'

    def resolve(collection_id:, label:, token:)
      result = { status: false, data: nil, message: '' }
      if token != ADMIN_WEB_TOKEN
        return OpenStruct.new(result.merge({message: I18n.t('admin.invalid_token')}))
      end

      messages = []
      label = normalize_label(label)
      collection = Collection.find_by(id: collection_id)

      messages << I18n.t('collection.invalid') unless collection.present?

      if messages.present?
        return OpenStruct.new(result.merge({message: messages.join(',')}))
      end

      ProjectCollectionRef.create!(project_name: label, collection_id: collection.id)

      OpenStruct.new(result.merge({status: true, data: collection}))
    rescue => ex
      OpenStruct.new(
        result.merge(
          {
            status: false,
            message: I18n.t('collection.append_project_failed', reason: ex.message)
          }
        )
      )
    end
  end
end
