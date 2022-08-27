# frozen_string_literal: true

module Types
  class CodequalityMetricType < Types::BaseObject
    field :code_quality_guarantee, Float, description: 'score of code quality metric model'
    field :code_merge_ratio, Float, description: 'ratio of merge pulls and all pulls'
    field :code_review_ratio, Float, description: 'ratio of pulls with one more reviewers and all pulls'
    field :commit_frequency, Float, description: 'mean of submissions per week over the past 90 days'
    field :contributor_count, Float, description: 'number of active D1 developers in the past 90 days'
    field :is_maintained, Boolean, description: 'maintenance status'
    field :pr_issue_linked_ratio, Float, description: 'ratio of pulls which are linked issues and all pulls'
    field :loc_frequency, Float, description: 'average of lines code each commit'
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric model creatiton time'
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level'
  end
end
