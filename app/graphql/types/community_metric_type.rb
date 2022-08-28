# frozen_string_literal: true

module Types
  class CommunityMetricType < Types::BaseObject
    field :community_support_score, Float, description: 'score of community support metric model'
    field :closed_prs_count, Float, description: 'number of pulls closed in the past 90 days'
    field :code_review_count, Float, description: 'mean of comments per PR over the past 90 days'
    field :comment_frequency, Float, description: 'mean of comments per issue over the past 90 days'
    field :issue_first_reponse_avg, Float, description: 'mean of issues first response time (days)'
    field :issue_first_reponse_mid, Float, description: 'middle of issues first response time (days)'
    field :issue_open_time_avg, Float, description: 'mean of issues open time (days)'
    field :issue_open_time_mid, Float, description: 'middle of issues open time (days)'
    field :updated_issues_count, Float, description: 'number of issue updates in the past 90 days'
    field :pr_open_time_avg, Float, description: 'mean of pulls open time (days)'
    field :pr_open_time_mid, Float, description: 'middle of pulls open time (days)'
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric model creatiton time'
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level'
  end
end
