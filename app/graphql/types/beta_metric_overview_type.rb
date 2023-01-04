# frozen_string_literal: true

module Types
  class BetaMetricOverviewType < Types::BaseObject
    field :projects_count, Integer
    field :trends, [Types::BetaRepoType]
  end
end
