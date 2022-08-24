# frozen_string_literal: true

module Types
  class RepoType < Types::BaseObject
    field :origin, String, null: false
    field :name, String
    field :language, String
    field :path, String
    field :backend, String
    field :pulls_count, Integer
    field :issues_count, Integer
    field :forks_count, Integer
    field :watchers_count, Integer
    field :stargazers_count, Integer
    field :open_issues_count, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
