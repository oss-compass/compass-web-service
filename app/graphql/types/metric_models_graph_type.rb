# frozen_string_literal: true

module Types
  class MetricModelsGraphType < Types::BaseObject
    field :productivity, [Types::Metric::ModelType], null: false
    field :robustness, [Types::Metric::ModelType], null: false
    field :niche_creation, [Types::Metric::ModelType], null: false
    field :type, String, description: 'metric scores for repositories type, only for community (software-artifact/governance)'
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level'

    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
