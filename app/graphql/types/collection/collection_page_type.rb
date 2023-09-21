# frozen_string_literal: true

module Types
  module Collection
    class CollectionPageType < BasePageObject
      field :items, [Types::RepoType]
    end
  end
end
