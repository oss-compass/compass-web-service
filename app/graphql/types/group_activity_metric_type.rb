# frozen_string_literal: true

module Types
  class GroupActivityMetricType < Types::BaseObject
    field :organizations_activity, Float, description: 'score of organization activity metric model'
    field :commit_frequency, Float, description: 'mean of submissions per week over the past 90 days'
    field :commit_frequency_org, Float, description: 'mean of org submissions per week over the past 90 days'
    field :commit_frequency_org_percentage, Float, description: 'percentage of org submissions per week over the past 90 days'
    field :commit_frequency_percentage, Float, description: 'percentage of submissions per week over the past 90 days'
    field :contribution_last, Float, description: '(average of months from the last org code commit to the time of statistics'
    field :contributor_count, Float, description: 'number of active D1 developers in the past 90 days'
    field :contributor_org_count, Float, description: 'number of active orgs in the past 90 days'
    field :is_org, Boolean, description: 'is org'
    field :org_count, Float, description: 'organization count'
    field :org_name, String, description: 'organization name'
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric model creatiton time'
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level'
  end
end
