# frozen_string_literal: true

module Types
  class GroupActivitySummaryType < Types::BaseObject
    field :organizations_activity, MetricStatType, description: 'score of organization activity metric model'
    field :commit_frequency, MetricStatType, description: 'mean of submissions per week over the past 90 days'
    field :contribution_last, MetricStatType, description: '(average of months from the last org code commit to the time of statistics'
    field :contributor_count, MetricStatType, description: 'number of active D1 developers in the past 90 days'
    field :org_count, MetricStatType, description: 'organization count'
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric summary creatiton time'
  end
end
