# frozen_string_literal: true

module Types
  class LatestMetricsType < Types::BaseObject
    field :activity_score, Float, description: 'latest score of activity metric model'
    field :activity_score_updated_at, GraphQL::Types::ISO8601DateTime, description: 'latest score of activity metric model updated_at'
    field :community_support_score, Float, description: 'latest score of community support metric model'
    field :community_support_score_updated_at, GraphQL::Types::ISO8601DateTime, description: 'latest score of community support metric model up'
    field :code_quality_guarantee, Float, description: 'latest score of code quality metric model'
    field :code_quality_guarantee_updated_at, GraphQL::Types::ISO8601DateTime, description: 'latest score of code quality metric model updated_at'
    field :organizations_activity, Float, description: 'latest score of organizations activity metric model'
    field :organizations_activity_updated_at, GraphQL::Types::ISO8601DateTime, description: 'latest score of organizations activity metric model updated_at'
    field :repos_count, Float, description: 'repositories count'
    field :origin, String, description: 'repositories origin'
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level'
  end
end
