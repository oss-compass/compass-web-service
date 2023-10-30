# frozen_string_literal: true

module Types
  module Meta
    class IssueDetailOverviewType < Types::BaseObject
      field :issue_count, Integer
      field :issue_completion_count, Integer
      field :issue_completion_ratio, Float
      field :issue_unresponsive_count, Integer
      field :issue_unresponsive_ratio, Float
      field :issue_comment_frequency_mean, Float
      field :issue_state_distribution, [DistributionType]
      field :issue_comment_distribution, [DistributionType]
    end
  end
end
