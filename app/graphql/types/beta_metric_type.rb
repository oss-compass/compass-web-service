# frozen_string_literal: true

module Types
  class BetaMetricType < Types::BaseObject
    field :id, Integer
    field :dimensionality, String
    field :metric, String
    field :desc, String
    field :status, String
    field :extra, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
