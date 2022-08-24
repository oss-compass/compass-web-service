# frozen_string_literal: true

module Types
  class OverviewType < Types::BaseObject
    field :repos_count, Integer
    field :stargazers_count, Integer
    field :pulls_count, Integer
    field :issues_count, Integer
    field :subscribers_count, Integer
    field :trends, [Types::RepoType]
  end
end
