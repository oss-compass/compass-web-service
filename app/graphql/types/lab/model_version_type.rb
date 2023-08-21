# frozen_string_literal: true

module Types
  module Lab
    class ModelVersionType < Types::BaseObject
      field :id, Integer, null: false
      field :version, String
      field :trigger_status, String
      field :trigger_updated_at, GraphQL::Types::ISO8601DateTime
      field :dataset, DatasetType, null: false
      field :metrics, [ModelMetricType], null: false
      field :algorithm, AlgorithmType
    end
  end
end
