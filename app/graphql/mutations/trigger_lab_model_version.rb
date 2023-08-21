# frozen_string_literal: true

module Mutations
  class TriggerLabModelVersion < BaseMutation
    field :status, String, null: false

    argument :model_id, Integer, required: true, description: 'lab model id'
    argument :version_id, Integer, required: true, description: 'lab model version id'

    def resolve(model_id:, version_id:)
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

      model_version = model.versions.find_by(id: version_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model_version.present?

      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).execute?

      raise GraphQL::ExecutionError.new I18n.t('lab_models.reaching_daily_limit') unless model.trigger_remaining_count > 0

      CustomAnalyzeServer.new({user: current_user, model: model, version: model_version}).execute
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.trigger_failed', reason: ex.message)
    end
  end
end
