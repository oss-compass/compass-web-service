# frozen_string_literal: true

module Mutations
  class CreateLabDataset < BaseMutation
    field :data, Types::Lab::DatasetType, null: true

    argument :version_id, Integer, required: true, description: 'lab model version id'
    argument :model_id, Integer, required: true, description: 'lab model  id'
    argument :datasets, [Input::DatasetRowTypeInput], required: true, description: 'the collection of the repositories'

    def resolve(
      model_id: nil,
      version_id: nil,
      datasets: nil
    )

      current_user = context[:current_user]
      dataset = nil
      version = nil
      report = nil
      login_required!(current_user)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.datasets_required') unless datasets.present?

      ActiveRecord::Base.transaction do
        version = LabModelVersion.find_by(id: version_id)
        # report = LabModelReport.create(lab_model_id: model_id, lab_model_version_id: version_id, user_id: current_user.id)
        # if report.errors.any?
        #   raise "Failed to create report: #{report.errors.full_messages.join(", ")}"
        # end
        report = LabModelReport.create!(lab_model_id: model_id, lab_model_version_id: version_id, user_id: current_user.id)
        puts report.inspect
        dataset = LabDataset.create_report_and_validate!(version, datasets,report)
        version.update!({ lab_dataset_id: dataset.id })
        report.update!({lab_dataset_id: dataset.id})
      end

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless version.present?

      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).execute?

      # raise GraphQL::ExecutionError.new I18n.t('lab_models.reaching_daily_limit') unless model.trigger_remaining_count > 0

      CustomAnalyzeReportServer.new({ user: current_user, model: model, version: version, report: report }).execute

      { data: dataset }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.create_failed', reason: ex.message)
    end

  end
end
