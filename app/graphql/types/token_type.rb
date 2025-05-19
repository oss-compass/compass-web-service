# frozen_string_literal: true

module Types
  class TokenType < Types::BaseObject
    field :id, Integer
    field :name, String
    field :token, String
    field :expires_at, GraphQL::Types::ISO8601DateTime

  end
end
