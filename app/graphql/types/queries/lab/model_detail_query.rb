# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class ModelDetailQuery < BaseQuery

        type Types::Lab::ModelDetailType, null: true
        description 'Get detail data of a lab model'
        argument :model_id, Integer, required: true, description: 'lab model id'

        def resolve(model_id:)
          current_user = context[:current_user]

          login_required!(current_user)

          model = LabModel.find_by(id: model_id)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

          raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).view?
          model
        end
      end
    end
  end
end
