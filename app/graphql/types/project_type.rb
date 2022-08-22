# frozen_string_literal: true

module Types
  class ProjectType < Types::BaseObject
    field :id, ID, null: false
    field :name, String
    field :language, String
    field :hash, String
    field :path, String
    field :backend, String
    field :html_url, String
    field :forks_count, Integer
    field :watchers_count, Integer
    field :stargazers_count, Integer
    field :open_issues_count, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
