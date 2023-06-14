# frozen_string_literal: true

module Types
  class GroupActivityMetricType < Types::BaseObject
    field :organizations_activity, Float, description: 'score of organization activity metric model'
    field :commit_frequency, Float, description: 'mean of submissions per week over the past 90 days'
    field :contribution_last, Float, description: '(average of months from the last org code commit to the time of statistics'
    field :contributor_count, Float, description: 'number of active D1 developers in the past 90 days'
    field :org_count, Float, description: 'organization count'
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric model creatiton time'
    field :type, String, description: 'metric scores for repositories type, only for community (software-artifact/governance)'
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level'
    field :short_code, String, description: 'metric model object short code'
  end
end
