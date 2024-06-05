# frozen_string_literal: true

module Types
  class SubjectSigMetricDetailType < Types::BaseObject
    field :date, GraphQL::Types::ISO8601DateTime
    field :score, Float
  end
end
