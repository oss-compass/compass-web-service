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
      field :pull_state_distribution, [DistributionType]
      field :pull_comment_distribution, [DistributionType]
    end
  end
end
