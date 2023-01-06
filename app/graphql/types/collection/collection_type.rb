# frozen_string_literal: true

module Types
  module Collection
    class CollectionType < Types::BaseObject
      field :id, Integer
      field :title, String
      field :desc, String
    end
  end
end
