# frozen_string_literal: true

module Types
  module Collection
    class CollectionPageType < Types::BaseObject
      field :count, Integer
      field :total_page, Integer
      field :page, Integer
      field :items, [Types::RepoType]
    end
  end
end
