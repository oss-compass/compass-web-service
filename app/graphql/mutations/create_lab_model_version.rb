# frozen_string_literal: true

module Mutations
  class CreateLabModelVersion < BaseMutation
    field :data, Types::Lab::ModelVersionType, null: true

    argument :model_id, Integer, required: true, description: 'lab model id'
    argument :version, String, required: true, description: 'version number'
    argument :datasets, [Input::DatasetRowTypeInput], required: true, description: 'the url collection of the repositories'
    argument :metrics, [Input::LabModelMetricInput], required: true, description: 'lab model metrics'
    argument :algorithm, String, required: false, description: 'the algorithm of the model, default: `default apm algorithm`'

    def resolve(
          model_id: nil,
          version: '',
          datasets: [],
          metrics: [],
          algorithm: 'default'
        )

      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.metrics_required') unless metrics.present?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.datasets_required') unless datasets.present?

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).create_version?

      model_version = nil
      algorithm = LabAlgorithm.find_by(ident: algorithm)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.invalid_algorithm') unless algorithm.present?
      ActiveRecord::Base.transaction do
        # When initializing a new version, the dataset is temporarily unbound
        model_version = model.versions.create!(version: version, algorithm: algorithm, lab_dataset_id: 0)
        dataset = LabDataset.create_and_validate!(model_version, datasets)
        metrics = LabModelMetric.bulk_create_and_validate!(model_version, metrics)
        model_version.update!({ lab_dataset_id: dataset.id })
      end
      { data: model_version }
    end
  end
end
