# frozen_string_literal: true

module Mutations
  class CreateLabModel < BaseMutation

    field :data, Types::Lab::ModelDetailType, null: true

    argument :name, String, required: true, description: 'lab model name'
    argument :dimension, Integer, required: true, description: 'lab model dimension: `productivity => 0, robustness => 1, niche_creation => 2, default: 0`'
    argument :is_public, Boolean, required: true, description: 'whether or not a public model, default: false'
    argument :is_general, Boolean, required: true, description: 'whether or not a generic domain model, default: true'
    argument :datasets, [Input::DatasetRowTypeInput], required: true, description: 'the collection of the repositories'
    argument :metrics, [Input::LabModelMetricInput], required: true, description: 'lab model metrics'
    argument :algorithm, String, required: false, description: 'the algorithm of the model, default: `default`'

    def resolve(name: nil,
                dimension: nil,
                is_public: false,
                is_general: true,
                datasets: [],
                metrics: [],
                algorithm: 'default')
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.metrics_required') unless metrics.present?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.datasets_required') unless datasets.present?

      name = name.strip
      raise GraphQL::ExecutionError.new I18n.t('lab_models.invalid_name') if name.blank?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.invalid_dimension') unless LabModel::Dimensions.include?(dimension)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.metrics_too_large', limit: LabMetric::Limit) if metrics.length > LabMetric::Limit

      algorithm = LabAlgorithm.find_by(ident: algorithm)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.invalid_algorithm') unless algorithm.present?

      model = nil

      ActiveRecord::Base.transaction do
        model =
          current_user.lab_models.create!(
            {
              name: name,
              dimension: dimension,
              is_public: is_public,
              is_general: is_general,
            }
          )

        # When initializing a new version, the dataset is temporarily unbound
        version = model.versions.create!(algorithm: algorithm, lab_dataset_id: 0)
        model.members.create!(user: current_user, permission: LabModelMember::All)
        dataset = LabDataset.create_and_validate!(version, datasets)
        metrics = LabModelMetric.bulk_create_and_validate!(version, metrics)
        version.update!({ lab_dataset_id: dataset.id })
      end

      { data: model }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.create_failed', reason: ex.message)
    end
  end
end
