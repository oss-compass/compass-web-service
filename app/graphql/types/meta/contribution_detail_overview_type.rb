# frozen_string_literal: true

module Types
  module Meta
    class ContributionDetailOverviewType < Types::BaseObject
      field :commit, Float
      field :pull, Float
      field :issue, Float
      field :contributor, Float
      field :org, Float
      field :star, Float
      field :fork, Float
      field :watch, Float
    end
  end
end
