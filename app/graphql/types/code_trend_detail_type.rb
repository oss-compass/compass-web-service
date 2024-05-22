# frozen_string_literal: true

module Types
  class CodeTrendDetailType < Types::BaseObject
    field :date, GraphQL::Types::ISO8601DateTime
    field :count, Integer
  end
end
