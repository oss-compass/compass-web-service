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
    end
  end
end
