# frozen_string_literal: true

module Types
  class OverviewType < Types::BaseObject
    field :projects_count, Integer
    field :dimensions_count, Integer
    field :models_count, Integer
    field :metrics_count, Integer
    field :trends, [Types::RepoType]
  end
end
