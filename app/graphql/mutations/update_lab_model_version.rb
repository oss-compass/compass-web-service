# frozen_string_literal: true

module Mutations
  class UpdateLabModelVersion < BaseMutation
    field :data, Types::Lab::ModelVersionType, null: true

    argument :model_id, Integer, required: true, description: "lab model id"
    argument :version_id, Integer, required: true, description: "lab model version id"
    argument :version, String, required: false, description: "version string"
    argument :is_score, Boolean, required: false, description: 'whether or not calculate the score, default: false'
    argument :datasets, [Input::DatasetRowTypeInput], required: false, description: 'the collection of the repositories'
    argument :metrics, [Input::LabModelMetricInput], required: false, description: 'lab model metrics'
    argument :algorithm, String, required: false, description: 'the ident of algorithm'

    def resolve(
          model_id: nil,
          version_id: nil,
          version: '',
          is_score:false,
          datasets: [],
          metrics: [],
          algorithm:
        )
      current_user = context[:current_user]

      login_required!(current_user)

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

      model_version = model.versions.find_by(id: version_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model_version.present?

      # raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).update?
      message = nil
      unless ::Pundit.policy(current_user, model).update?
        # fork
        user_id = current_user.id
        query1 = LabModel.where(user_id: user_id, parent_model_id: model_id)
        if model.parent_model_id.present?
          query2 = LabModel.where(user_id: user_id, parent_model_id: model.parent_model_id)
          exist_model = query1.or(query2).first
        else
          exist_model = query1.first
        end

        ActiveRecord::Base.transaction do
          if exist_model.present?
            # create a new version
            model_version = exist_model.versions.create!(algorithm: model_version.algorithm, lab_dataset_id: 0, is_score: model_version.is_score)
            LabModelMetric.create_by_metric_version(model_version, metrics)

          else
            # create a new model, new version
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

            model_version = model.versions.create!(algorithm: model_version.algorithm, lab_dataset_id: 0, is_score: model_version.is_score, parent_lab_model_version_id: version_id)
            model.members.create!(user: current_user, permission: LabModelMember::All)
            LabModelMetric.create_by_metric_version(model_version, metrics)
          end
         message= "Fork Success"
        end

      end

      raise GraphQL::ExecutionError.new I18n.t('lab_models.metrics_too_large', limit: LabMetric::Limit) if metrics.length > LabMetric::Limit

      if algorithm.present?
        algorithm = LabAlgorithm.find_by(ident: algorithm)
        raise GraphQL::ExecutionError.new I18n.t('lab_models.invalid_algorithm') unless algorithm.present?
        end

      ActiveRecord::Base.transaction do

        if algorithm.present?
          model_version.update!(algorithm: algorithm)
        end

        if datasets.present?
          model_version.dataset.update_rows!(datasets)
        end

        if metrics.present?
          model_version.bulk_update_or_create!(metrics)
        end

        if version.present?
          model_version.update!(version: version)
        end

        if is_score != nil
          model_version.update!(is_score: is_score)
        end


      end

      { data: model_version, message: message }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.update_failed', reason: ex.message)
    end
  end
end
