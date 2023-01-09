# frozen_string_literal: true

module Types
  module Queries
    module Collections
      class CollectionDetailQuery < BaseQuery
        include Pagy::Backend

        type Types::Collection::CollectionDetailType, null: false
        description 'Get detail data of a collection'
        argument :id, Integer, required: true, description: 'collection id'

        def resolve(id:)
          ::Collection.find_by(id: id)
        end
      end
    end
  end
end
