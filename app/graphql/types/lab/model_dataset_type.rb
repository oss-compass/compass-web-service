# frozen_string_literal: true

module Types
  module Lab
    class ModelDatasetType < Types::BaseObject
      field :id, Integer, null: false
      field :dataset_id, Integer, null: false
      field :lab_model_version_id, Integer
      field :create_at, GraphQL::Types::ISO8601DateTime
    end
  end
end
