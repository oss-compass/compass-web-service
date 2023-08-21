# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class ModelVersionQuery < BaseQuery

        type Types::Lab::ModelVersionType, null: true
        description 'Get detail data of a lab model version'
        argument :model_id, Integer, required: true, description: 'lab model id'
        argument :version_id, Integer, required: true, description: 'lab model version id'

        def resolve(model_id: nil, version_id: nil)
          current_user = context[:current_user]
          raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?
          model = LabModel.find_by(id: model_id)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

          raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).view?

          model_version = model.versions.find_by(id: version_id)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model_version.present?

          model_version
        end
      end
    end
  end
end
