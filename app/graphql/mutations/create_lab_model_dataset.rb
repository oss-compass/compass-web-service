# frozen_string_literal: true

module Mutations
  class CreateLabModelDataset < BaseMutation

    field :data, Types::Lab::ModelDatasetType, null: true

    argument :model_id, Integer, required: true, description: "lab model id"
    argument :version_id, Integer, required: true, description: "lab model version id"
    argument :dataset_id, Integer, required: true, description: "lab  dataset id"

    def resolve(
      model_id: nil,
      version_id: nil,
      dataset_id: nil
    )
      current_user = context[:current_user]

      login_required!(current_user)

      dataset = LabDataset.find_by(id: dataset_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless dataset.present?

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

      model_version = model.versions.find_by(id: version_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model_version.present?

      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).update?

      ActiveRecord::Base.transaction do
        LabModelDataset.create(lab_model_version_id: version_id, lab_dataset_id: dataset_id)
      end

      { data: model_version }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.update_failed', reason: ex.message)
    end
  end
end
