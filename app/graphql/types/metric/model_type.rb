# frozen_string_literal: true
module Types
  module Metric
    class ModelType < Types::BaseObject
      field :dimension, String, description: 'dimension of metric model'
      field :scope, String, description: 'scope of metric model'
      field :ident, String, null: false, description: 'metric model ident'
      field :type, String, description: 'metric scores for repositories type, only for community (software-artifact/governance)'
      field :label, String, description: 'metric model object identification'
      field :level, String, description: 'metric model object level'
      field :main_score, Float, description: 'metric model main score'
      field :transformed_score, Float, description: 'metric model transformed score'
      field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime, description: 'metric model create or update time'
      field :updated_at, GraphQL::Types::ISO8601DateTime, description: 'metric model update time'
    end
  end
end
