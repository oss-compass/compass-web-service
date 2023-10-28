# frozen_string_literal: true

module Types
  module Meta
    class PullDetailOverviewType < Types::BaseObject
      field :pull_count, Integer
      field :pull_completion_count, Integer
      field :pull_completion_ratio, Float
      field :pull_unresponsive_count, Integer
      field :pull_unresponsive_ratio, Float
      field :commit_count, Integer
    end
  end
end
