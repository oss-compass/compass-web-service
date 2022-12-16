# frozen_string_literal: true

module Types
  class CodequalitySummaryType < Types::BaseObject
    field :code_quality_guarantee, MetricStatType, description: 'score of code quality metric model'
    field :code_merge_ratio, MetricStatType, description: 'ratio of merge pulls and all pulls'
    field :code_merged_count, MetricStatType, description: 'merged pr count past 90 days'
    field :code_review_ratio, MetricStatType, description: 'ratio of pulls with one more reviewers and all pulls'
    field :code_reviewed_count, MetricStatType, description: 'count of pulls with one more reviewers'
    field :commit_frequency, MetricStatType, description: 'mean of submissions per week over the past 90 days'
    field :commit_frequency_inside, MetricStatType, description: 'mean of inside submissions per week over the past 90 days'
    field :active_c1_pr_create_contributor_count, MetricStatType, description: 'number of active C1 pr create contributors in the past 90 days'
    field :active_c1_pr_comments_contributor_count, MetricStatType, description: 'number of active C1 pr comments contributors in the past 90 days'
    field :active_c2_contributor_count, MetricStatType, description: 'number of active C2 developers in the past 90 days'
    field :contributor_count, MetricStatType, description: 'number of active D1 developers in the past 90 days'
    field :is_maintained, MetricStatType, description: 'maintenance status'
    field :pr_issue_linked_ratio, MetricStatType, description: 'ratio of pulls which are linked issues and all pulls'
    field :pr_issue_linked_count, MetricStatType, description: 'count of pulls which are linked issues'
    field :loc_frequency, MetricStatType, description: 'average of lines code each commit'
    field :lines_added_frequency, MetricStatType, description: 'average of added lines code each commit'
    field :lines_removed_frequency, MetricStatType, description: 'average of removed lines code each commit'
    field :pr_count, MetricStatType, description: 'all pr count past 90 days'
    field :pr_commit_count, MetricStatType, description: 'pr count base for pr_commit_linked_count past 90 days'
    field :pr_commit_linked_count, MetricStatType, description: 'pr with commits linked count past 90 days'
    field :git_pr_linked_ratio, MetricStatType, description: 'ratio of pr_commit_linked_count and pr_commit_count'
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric summary creatiton time'
  end
end
