# frozen_string_literal: true

module Types
  class BetaMetricScoreType < Types::BaseObject
    field :name, String, description: 'name of this beta metric'
    field :score, Float, description: 'score of this beta metric'
    field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric model creatiton time'
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level'
  end
end
