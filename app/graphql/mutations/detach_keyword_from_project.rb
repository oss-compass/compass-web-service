module Mutations
  class DetachKeywordFromProject < BaseMutation
    include Common
    graphql_name 'DetachKeywordFromProject'

    field :status, String, null: false
    field :data, Types::Project::ProjectDetailType

    argument :label, String, required: true, description: 'repo or community label'
    argument :keyword_id, Integer, required: true, description: 'keyword id'
    argument :token, String, required: true, description: 'admin token'

    def resolve(label:, keyword_id:, token:)
      result = { status: false, data: nil, message: '' }
      if token != ADMIN_WEB_TOKEN
        return OpenStruct.new(result.merge({message: I18n.t('admin.invalid_token')}))
      end

      messages = []
      label = normalize_label(label)
      p_key_ref = ProjectKeywordRef.find_by(project_name: label, keyword_id: keyword_id)

      messages << I18n.t('project.no_such_keyword') unless p_key_ref.present?

      if messages.present?
        return OpenStruct.new(result.merge({message: messages.join(',')}))
      end

      p_key_ref.destroy!

      keywords =
        Keyword.includes(:project_keyword_refs)
          .where(project_keyword_refs: { project_name: label })

      OpenStruct.new(result.merge({status: true, data: OpenStruct.new(label: label, keywords: keywords)}))
    rescue => ex
      OpenStruct.new(
        result.merge(
          {
            status: false,
            message: I18n.t('project.detach_keyword_failed', reason: ex.message)
          }
        )
      )
    end
  end
end
