# frozen_string_literal: true

module Mutations
  class CreateLabModel < BaseMutation

    field :data, Types::Lab::ModelDetailType, null: true

    argument :name, String, required: true, description: 'lab model name'
    argument :description, String, required: false, description: 'lab model description'
    argument :is_public, Boolean, required: true, description: 'whether or not a public model, default: false'
    argument :is_score, Boolean, required: true, description: 'whether or not calculate the score, default: false'
    argument :metrics, [Input::LabModelMetricInput], required: true, description: 'lab model metrics'
    argument :algorithm, String, required: false, description: 'the algorithm of the model, default: `default`'

    def resolve(name: nil,
                is_public: false,
                is_score: false,
                metrics: [],
                description: nil,
                algorithm: 'default')
      current_user = context[:current_user]

      login_required!(current_user)

      raise GraphQL::ExecutionError.new I18n.t('lab_models.metrics_required') unless metrics.present?

      name = name.strip
      raise GraphQL::ExecutionError.new I18n.t('lab_models.invalid_name') if name.blank?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.metrics_too_large', limit: LabMetric::Limit) if metrics.length > LabMetric::Limit

      algorithm = LabAlgorithm.find_by(ident: algorithm)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.invalid_algorithm') unless algorithm.present?

      model = nil

      ActiveRecord::Base.transaction do
        model =
          current_user.lab_models.create!(
            {
              name: name,
              dimension: 0,
              description: description,
              is_public: is_public,
              is_general: true,
            }
          )

        # When initializing a new version, the dataset is temporarily unbound
        version = model.versions.create!(algorithm: algorithm, lab_dataset_id: 0,is_score:is_score)
        model.members.create!(user: current_user, permission: LabModelMember::All)
        metrics = LabModelMetric.bulk_create_and_validate!(version, metrics)
      end

      { data: model }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.create_failed', reason: ex.message)
    end
  end
end
