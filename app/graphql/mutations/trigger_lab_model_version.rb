# frozen_string_literal: true

module Mutations
  class TriggerLabModelVersion < BaseMutation
    field :status, String, null: false

    # argument :model_id, Integer, required: true, description: 'lab model id'
    # argument :version_id, Integer, required: true, description: 'lab model version id'
    argument :report_id, Integer, required: true, description: 'lab model report id'

    def resolve(report_id: nil)
      current_user = context[:current_user]

      login_required!(current_user)

      report = LabModelReport.find_by(id: report_id)

      model = LabModel.find_by(id: report.lab_model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

      model_version = model.versions.find_by(id: report.lab_model_version_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model_version.present?

      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).execute?

      # raise GraphQL::ExecutionError.new I18n.t('lab_models.reaching_daily_limit') unless model.trigger_remaining_count > 0

      # CustomAnalyzeServer.new({ user: current_user, model: model, version: model_version }).execute
      CustomAnalyzeReportServer.new({ user: current_user, model: model, version: model_version,report: report }).execute
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.trigger_failed', reason: ex.message)
    end
  end
end
