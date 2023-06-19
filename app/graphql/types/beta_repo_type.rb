# frozen_string_literal: true

module Types
  class BetaRepoType < Types::BaseObject
    field :origin, String, null: false
    field :name, String
    field :short_code, String
    field :language, String
    field :path, String
    field :backend, String
    field :beta_metric_scores, [Types::BetaMetricScoreType], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
