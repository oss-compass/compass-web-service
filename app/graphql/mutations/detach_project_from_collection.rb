module Mutations
  class DetachProjectFromCollection < BaseMutation
    include Common
    graphql_name 'DetachProjectFromCollection'

    field :status, String, null: false
    field :data, Types::Collection::CollectionDetailType

    argument :label, String, required: true, description: 'repo or community label'
    argument :collection_id, Integer, required: true, description: 'collection id'
    argument :token, String, required: true, description: 'admin token'

    def resolve(label:, collection_id:, token:)
      result = { status: false, data: nil, message: '' }
      if token != ADMIN_WEB_TOKEN
        return OpenStruct.new(result.merge({message: I18n.t('admin.invalid_token')}))
      end

      messages = []
      label = normalize_label(label)
      collection = Collection.find_by(id: collection_id)
      collection_ref = collection.project_collection_refs.find_by(project_name: label)

      messages << I18n.t('collection.no_such_project') unless collection_ref.present?
      messages << I18n.t('collection.invalid') unless collection.present?

      if messages.present?
        return OpenStruct.new(result.merge({message: messages.join(',')}))
      end

      collection_ref.destroy!

      OpenStruct.new(result.merge({status: true, data: collection}))
    rescue => ex
      OpenStruct.new(
        result.merge(
          {
            status: false,
            message: I18n.t('collection.detach_project_failed', reason: ex.message)
          }
        )
      )
    end
  end
end
