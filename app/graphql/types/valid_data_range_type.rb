# frozen_string_literal: true

module Types
  class ValidDataRangeType < Types::BaseObject
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level (project or repo)'
    field :short_code, String, description: 'metric model object short code'
    field :status, Boolean, description: 'whether it is a valid data range'
    field :min, GraphQL::Types::ISO8601DateTime, description: 'min valid date'
    field :max, GraphQL::Types::ISO8601DateTime, description: 'max valid date'
  end
end
