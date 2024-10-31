# frozen_string_literal: true

module Types
  module Lab
    class MyModelVersionType < Types::BaseObject
      field :id, Integer, null: false
      field :versionId, Integer, null: false
      field :modelId, Integer, null: false
      field :reportId, Integer, null: false
      field :parent_model_id, Integer
      field :is_public, Boolean

      field :version, String
      field :modelName, String
      field :trigger_status, String
      field :trigger_updated_at, GraphQL::Types::ISO8601DateTime
      field :dataset, DatasetType
      field :metrics, [ModelMetricType], null: true
      field :algorithm, AlgorithmType
      field :parent_lab_model, ModelDetailType

      def parent_lab_model
        LabModel.find_by(id: model.parent_model_id)
      end

      def model
        @model ||= object
      end
    end
  end
end
