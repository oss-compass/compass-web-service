# frozen_string_literal: true

module Types
  class CodequalityMetricType < Types::BaseObject
    field :code_quality_guarantee, Float, description: 'score of code quality metric model'
    field :code_merge_ratio, Float, description: 'ratio of merge pulls and all pulls'
    field :code_merged_count, Float, description: 'merged pr count past 90 days'
    field :code_review_ratio, Float, description: 'ratio of pulls with one more reviewers and all pulls'
    field :code_reviewed_count, Float, description: 'count of pulls with one more reviewers'
    field :commit_frequency, Float, description: 'mean of submissions per week over the past 90 days'
    field :commit_frequency_inside, Float, description: 'mean of inside submissions per week over the past 90 days'
    field :active_c1_pr_create_contributor_count, Float, description: 'number of active C1 pr create contributors in the past 90 days'
    field :active_c1_pr_comments_contributor_count, Float, description: 'number of active C1 pr comments contributors in the past 90 days'
    field :active_c2_contributor_count, Float, description: 'number of active C2 developers in the past 90 days'
    field :contributor_count, Float, description: 'number of active D1 developers in the past 90 days'
    field :is_maintained, Float, description: 'maintenance status'
    field :pr_issue_linked_ratio, Float, description: 'ratio of pulls which are linked issues and all pulls'
    field :pr_issue_linked_count, Float, description: 'count of pulls which are linked issues'
    field :loc_frequency, Float, description: 'average of lines code each commit'
    field :lines_added_frequency, Float, description: 'average of added lines code each commit'
    field :lines_removed_frequency, Float, description: 'average of removed lines code each commit'
    field :pr_count, Float, description: 'all pr count past 90 days'
    field :pr_commit_count, Float, description: 'pr count base for pr_commit_linked_count past 90 days'
    field :pr_commit_linked_count, Float, description: 'pr with commits linked count past 90 days'
    field :git_pr_linked_ratio, Float, description: 'ratio of pr_commit_linked_count and pr_commit_count'
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric model creatiton time'
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level'
  end
end
