# frozen_string_literal: true

module Types
  module Queries
    module Keywords
      class KeywordOverviewQuery < BaseQuery
        include Pagy::Backend

        type Types::Keyword::KeywordOverviewType, null: false
        description 'Get overview data of all keywords'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'

        def resolve(page: 1, per: 9)
          pagyer, records = pagy(::Keyword.all, { page: page, items: per })
          OpenStruct.new({count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records})
        end
      end
    end
  end
end
