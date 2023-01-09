# frozen_string_literal: true

module Types
  module Collection
    class CollectionDetailType < Types::BaseObject
      field :id, Integer
      field :title, String
      field :desc, String
      field :projects, [String]
      field :keywords, [Types::Keyword::KeywordType]
      field :created_at, GraphQL::Types::ISO8601DateTime
      field :updated_at, GraphQL::Types::ISO8601DateTime
    end
  end
end
