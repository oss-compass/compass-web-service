# frozen_string_literal: true

module Types
  class RepoType < Types::BaseObject
    field :origin, String, null: false
    field :name, String
    field :type, String
    field :language, String
    field :path, String
    field :backend, String
    field :forks_count, Integer
    field :watchers_count, Integer
    field :stargazers_count, Integer
    field :open_issues_count, Integer
    field :metric_activity, [Types::ActivityMetricType], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
