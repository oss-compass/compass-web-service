# frozen_string_literal: true

module Types
  module Collection
    class CollectionOverviewType < Types::BaseObject
      field :count, Integer
      field :total_page, Integer
      field :page, Integer
      field :items, [Types::Collection::CollectionType]
    end
  end
end
