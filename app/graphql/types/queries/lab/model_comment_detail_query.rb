# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class ModelCommentDetailQuery < BaseQuery
        type Types::Lab::ModelCommentType, null: true
        description 'Get comment detail data with comment id'
        argument :model_id, Integer, required: true, description: 'lab model id'
        argument :comment_id, Integer, required: true, description: 'lab model comment id'

        def resolve(
              model_id: nil,
              comment_id: nil
            )
          current_user = context[:current_user]
          raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

          model = LabModel.find_by(id: model_id)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

          raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).view?
          model.comments.find_by(id: comment_id)
        end
      end
    end
  end
end
