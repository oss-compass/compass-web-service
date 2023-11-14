# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class ModelCommentsQuery < BaseQuery
        include Pagy::Backend

        type Types::Lab::ModelCommentPageType, null: true
        description 'Get comments data of a lab model'
        argument :model_id, Integer, required: true, description: 'lab model id'
        argument :version_id, Integer, required: false, description: 'lab model version id'
        argument :model_metric_id, Integer, required: false, description: 'lab model metric id'
        argument :parent_id, Integer, required: false, description: 'parent comment id'
        argument :sort, String, required: false, description: 'the field to sort by, `default: created_at`'
        argument :direction, String, required: false, description: 'the direction to sort, `default: desc`'
        argument :page, Integer, required: false, description: 'page number, `default: 1`'
        argument :per, Integer, required: false, description: 'per page number, `default: 9`'

        def resolve(
              model_id: nil,
              version_id: nil,
              model_metric_id: nil,
              parent_id: nil,
              sort: 'created_at',
              direction: 'desc',
              page: 1,
              per: 9
            )
          current_user = context[:current_user]

          login_required!(current_user)

          raise GraphQL::ExecutionError.new I18n.t('lab_models.reach_limit') if per > 20

          model = LabModel.find_by(id: model_id)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

          raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).view?

          comments = model.comments

          comments = comments.where(lab_model_version_id: version_id) if version_id.present?
          comments =  model_metric_id.present? ? comments.where(lab_model_metric_id: model_metric_id) : comments.where(lab_model_metric_id: nil)
          comments = parent_id.present? ? comments.where(reply_to: parent_id) : comments.where(reply_to: nil)
          comments = comments.order(sort => direction) if LabModelComment.sortable_fields.include?(sort) && LabModelComment.sortable_directions.include?(direction)

          pagyer, records = pagy(comments, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }
        end
      end
    end
  end
end
