# frozen_string_literal: true

module Types
  module Lab
    class MyModelVersionType < Types::BaseObject
      field :id, Integer, null: false
      field :versionId, Integer, null: false
      field :modelId, Integer, null: false
      field :reportId, Integer, null: false

      field :version, String
      field :modelName, String
      field :trigger_status, String
      field :trigger_updated_at, GraphQL::Types::ISO8601DateTime
      field :dataset, DatasetType
      field :metrics, [ModelMetricType], null: true
      field :algorithm, AlgorithmType
      # field :algorithm, Types::AlgorithmType, null: true

    end
  end
end
