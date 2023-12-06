# frozen_string_literal: true

module Types
  class RolePersonaMetricType < Types::BaseObject
    field :activity_organization_contributor_count, Float, description: 'activity organization contributor count'
    field :activity_organization_contribution_per_person, Float, description: 'activity organization contribution per person'
    field :activity_individual_contributor_count, Float, description: 'activity individual contributor count'
    field :activity_individual_contribution_per_person, Float, description: 'activity individual contribution per person'
    field :role_persona_score, Float, description: 'role persona score'
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric model creatiton time'
    field :type, String, description: 'metric scores for repositories type, only for community (software-artifact/governance)'
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level'
    field :short_code, String, description: 'metric model object short code'
  end
end
