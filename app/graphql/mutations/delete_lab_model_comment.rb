# frozen_string_literal: true

module Mutations
  class DeleteLabModelComment < BaseMutation
    field :status, String, null: false

    argument :model_id, Integer, required: true, description: 'lab model id'
    argument :comment_id, Integer, required: true, description: 'lab model comment id'

    def resolve(model_id: nil, comment_id: nil)

      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).view?

      comment = model.comments.find_by(id: comment_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless comment.present?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless current_user.id == comment.user_id
      comment.destroy!

      { status: true, message: I18n.t('lab_models.delete_success') }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.delete_failed', reason: ex.message)
    end
  end
end
