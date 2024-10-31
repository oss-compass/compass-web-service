# frozen_string_literal: true

module Types
  module Lab
    class ModelReportType < Types::BaseObject
      field :id, Integer, null: false
      field :lab_model_id, Integer, null: false
      field :lab_model_version_id, Integer, null: false
      field :lab_dataset_id, Integer, null: false
      field :user_id, Integer, null: false
      field :created_at, GraphQL::Types::ISO8601DateTime

    end
  end
end
