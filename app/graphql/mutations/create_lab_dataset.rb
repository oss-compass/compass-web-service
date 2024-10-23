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
      report = nil
      login_required!(current_user)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.datasets_required') unless datasets.present?

      model = LabModel.find_by(id: model_id)
      version = LabModelVersion.find_by(id: version_id)
      unless ::Pundit.policy(current_user, model).execute?
        # fork
        ActiveRecord::Base.transaction do
          model =
            current_user.lab_models.create!(
              {
                name: model.name,
                dimension: 0,
                description: model.description,
                is_public: false,
                is_general: true,
                parent_model_id: model.id
              }
            )
          metrics = version.metrics
          version = model.versions.create!(algorithm: version.algorithm, lab_dataset_id: 0, is_score: version.is_score)
          model.members.create!(user: current_user, permission: LabModelMember::All)
          metrics = LabModelMetric.bulk_create_and_validate!(version, metrics)
        end
      end


      ActiveRecord::Base.transaction do
        report = LabModelReport.create!(lab_model_id: model.id, lab_model_version_id: version.id, user_id: current_user.id)
        dataset = LabDataset.create_report_and_validate!(version, datasets, report)
        version.update!({ lab_dataset_id: dataset.id })
        report.update!({ lab_dataset_id: dataset.id })
      end


      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless version.present?

      # raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).execute?

      CustomAnalyzeReportServer.new({ user: current_user, model: model, version: version, report: report }).execute

      { data: dataset }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.create_failed', reason: ex.message)
    end

  end
end
