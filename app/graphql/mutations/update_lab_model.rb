# frozen_string_literal: true

module Mutations
  class UpdateLabModel < BaseMutation

    field :data, Types::Lab::ModelDetailType, null: true

    argument :model_id, Integer, required: true, description: 'lab model id'
    argument :name, String, required: false, description: 'lab model name'
    argument :description, String, required: false, description: 'lab model description'
    argument :is_public, Boolean, required: false, description: 'whether or not a public model, default: false'

    def resolve(
      description: nil,
      model_id: nil,
      name: nil,
      is_public: nil
      )

      current_user = context[:current_user]

      login_required!(current_user)

      name = name&.strip

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).update?

      update_set = {}
      update_set[:name] = name if name.present?
      update_set[:is_public] = is_public if is_public != nil
      update_set[:description] = description if description != nil
      model.update!(update_set) if update_set.present?

      { data: model }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.update_failed', reason: ex.message)
    end
  end
end
