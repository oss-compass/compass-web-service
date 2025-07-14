# frozen_string_literal: true

module Types
  class CriticalityScoreMetricType < Types::BaseObject
    field :criticality_score_score, Float, description: 'score of criticality score metric model'
    field :created_since, Float, description: 'Time since the project was created (in months)'
    field :updated_since, Float, description: 'Time since the project was last updated (in months)'
    field :contributor_count_all, Float, description: 'Count of project contributors (with commits)'
    field :org_count_all, Float, description: 'Count of distinct organizations that contributors belong to'
    field :commit_frequency_last_year, Float, description: 'Average number of commits per week in the last year'
    field :recent_releases_count, Float, description: 'Number of releases in the last year'
    field :closed_issues_count, Float, description: 'Number of issues closed in the last 90 days'
    field :updated_issues_count, Float, description: 'Number of issues updated in the last 90 days'
    field :comment_frequency, Float, description: 'Average number of comments per issue in the last 90 days'
    # field :dependents_count, Float, description: 'Number of project mentions in the commit messages'
    #
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric model creatiton time'
    field :type, String, description: 'metric scores for repositories type, only for community (software-artifact/governance)'
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level'
    field :short_code, String, description: 'metric model object short code'
  end
end
