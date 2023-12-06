# frozen_string_literal: true

module Types
  class MilestonePersonaMetricType < Types::BaseObject
    field :activity_casual_contributor_count, Float, description: 'number of casual contributors'
    field :activity_casual_contribution_per_person, Float, description: 'casual contributors per person'
    field :activity_regular_contributor_count, Float, description: 'number of regular contributors'
    field :activity_regular_contribution_per_person, Float, description: 'regular contributors per person'
    field :activity_core_contributor_count, Float, description: 'number of core contributors'
    field :activity_core_contribution_per_person, Float, description: 'core contributors per person'
    field :milestone_persona_score, Float, description: 'milestone persona score'
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric model creatiton time'
    field :type, String, description: 'metric scores for repositories type, only for community (software-artifact/governance)'
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level'
    field :short_code, String, description: 'metric model object short code'
  end
end
