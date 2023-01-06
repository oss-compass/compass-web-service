module Mutations
  class CreateCollection < BaseMutation
    include Common
    graphql_name 'CreateCollection'

    field :status, String, null: false
    field :id, Integer
    field :title, String
    field :desc, String

    argument :title, String, required: true, description: 'collection title'
    argument :desc, String, required: false, description: 'collection description'
    argument :token, String, required: true, description: 'admin token'

    def resolve(title:, desc: nil, token:)
      result = { id: nil, title: '', desc: '', status: false, message: '' }
      if token != ADMIN_WEB_TOKEN
        return OpenStruct.new(result.merge({message: I18n.t('admin.invalid_token')}))
      end
      collection = Collection.create!({title: title, desc: desc})
      OpenStruct.new(
        result.merge(
          {
            status: true,
            message: I18n.t('collection.create_success'),
            id: collection.id,
            desc: collection.desc,
            title: collection.title
          }
        )
      )
    rescue => ex
      OpenStruct.new(
        result.merge(
          {
            status: false,
            message: I18n.t('collection.create_failed', reason: ex.message)
          }
        )
      )
    end
  end
end
