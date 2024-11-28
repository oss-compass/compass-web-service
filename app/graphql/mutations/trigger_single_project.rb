# frozen_string_literal: true

module Mutations
  class TriggerSingleProject < BaseMutation
    field :status, String, null: false


    argument :report_id, Integer, required: true, description: 'lab model report id'
    argument :project_url, String, required: true, description: 'project url or community name'
    argument :level, String, required: true, description: 'level'

    def resolve(report_id: nil, project_url: nil, level: nil)
      current_user = context[:current_user]

      login_required!(current_user)

      report = LabModelReport.find_by(id: report_id)

      model = LabModel.find_by(id: report.lab_model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

      model_version = model.versions.find_by(id: report.lab_model_version_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model_version.present?

      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).execute?


      # raise GraphQL::ExecutionError.new I18n.t('lab_models.reaching_daily_limit') unless model.trigger_remaining_count > 0

      CustomAnalyzeProjectServer.new({ user: current_user, model: model, version: model_version, project: project_url, level: level }).execute
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.trigger_failed', reason: ex.message)
    end
  end
end
