# frozen_string_literal: true

module Mutations
  class UpdateLabModel < BaseMutation

    field :data, Types::Lab::ModelDetailType, null: true

    argument :model_id, Integer, required: true, description: 'lab model id'
    # argument :default_version_id, Integer, required: false, description: 'update the default version with pass version id'
    argument :name, String, required: false, description: 'lab model name'
    # argument :dimension, Integer, required: false, description: 'lab model dimension: `productivity => 0, robustness => 1, niche_creation => 2, default: 0`'
    argument :is_public, Boolean, required: false, description: 'whether or not a public model, default: false'
    # argument :is_general, Boolean, required: false, description: 'whether or not a generic domain model, default: true'

    def resolve(
      # default_version_id: nil,
      # dimension: nil,
      # # is_general: nil,
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
      # update_set[:dimension] = dimension if LabModel::Dimensions.include?(dimension)
      update_set[:is_public] = is_public if is_public != nil
      # update_set[:is_general] = is_general if is_general != nil
      # if default_version_id.present?
      #   version = model.versions.find_by(id: default_version_id)
      #   raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless version.present?
      #   update_set[:default_version_id] = version.id
      # end

      model.update!(update_set) if update_set.present?

      { data: model }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.update_failed', reason: ex.message)
    end
  end
end
