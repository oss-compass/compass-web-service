# frozen_string_literal: true

module Mutations
  class DeleteLabModelVersion < BaseMutation
    field :status, String, null: false

    argument :model_id, Integer, required: true, description: "lab model id"
    argument :version_id, Integer, required: true, description: "lab model version id"

    def resolve(model_id: nil, version_id: nil)
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

      version = model.versions.find_by(id: version_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless version.present?

      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).update?

      version.destroy!

      { status: true, message: I18n.t('lab_models.delete_success') }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.delete_failed', reason: ex.message)
    end
  end
end
