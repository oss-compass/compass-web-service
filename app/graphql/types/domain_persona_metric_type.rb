# frozen_string_literal: true

module Types
  class DomainPersonaMetricType < Types::BaseObject
    field :activity_observation_contributor_count, Float, description: 'activity observation contributor count'
    field :activity_observation_contribution_per_person, Float, description: 'activity observation contribution per person'
    field :activity_code_contributor_count, Float, description: 'activity code contributor count'
    field :activity_code_contribution_per_person, Float, description: 'activity code contribution per person'
    field :activity_issue_contributor_count, Float, description: 'activity issue contributor count'
    field :activity_issue_contribution_per_person, Float, description: 'activity issue contribution per person'
    field :domain_persona_score, Float, description: 'role persona score'
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric model creatiton time'
    field :type, String, description: 'metric scores for repositories type, only for community (software-artifact/governance)'
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level'
    field :short_code, String, description: 'metric model object short code'
  end
end
