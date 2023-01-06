# frozen_string_literal: true

module Types
  module Queries
    module Collections
      class CollectionOverviewQuery < BaseQuery
        include Pagy::Backend

        type Types::Collection::CollectionOverviewType, null: false
        description 'Get overview data of all collections'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'

        def resolve(page: 1, per: 9)
          pagyer, records = pagy(::Collection.all, { page: page, items: per })
          OpenStruct.new({count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records})
        end
      end
    end
  end
end
