# frozen_string_literal: true

module Types
  class CommunitySummaryType < Types::BaseObject
    field :community_support_score, MetricStatType, description: 'score of community support metric model'
    field :closed_prs_count, MetricStatType, description: 'number of pulls closed in the past 90 days'
    field :code_review_count, MetricStatType, description: 'mean of comments per PR over the past 90 days'
    field :comment_frequency, MetricStatType, description: 'mean of comments per issue over the past 90 days'
    field :issue_first_reponse_avg, MetricStatType, description: 'mean of issues first response time (days)'
    field :issue_first_reponse_mid, MetricStatType, description: 'middle of issues first response time (days)'
    field :bug_issue_open_time_avg, MetricStatType, description: 'mean of bug issues open time (days)'
    field :bug_issue_open_time_mid, MetricStatType, description: 'middle of bug issues open time (days)'
    field :issue_open_time_avg, MetricStatType, description: 'mean of issues open time (days)'
    field :issue_open_time_mid, MetricStatType, description: 'middle of issues open time (days)'
    field :updated_issues_count, MetricStatType, description: 'number of issue updates in the past 90 days'
    field :pr_open_time_avg, MetricStatType, description: 'mean of pulls open time (days)'
    field :pr_open_time_mid, MetricStatType, description: 'middle of pulls open time (days)'
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric summary creatiton time'
  end
end
