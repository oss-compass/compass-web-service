# frozen_string_literal: true

module Types
  module Queries
    class CollectionHottestQuery < BaseQuery

      type [ProjectCompletionRowType], null: false
      description 'Get hottest reports of a collection'
      argument :ident, String, required: true, description: 'collection ident'
      argument :level, String, required: false, description: 'filter by level, default: all'
      argument :limit, Integer, required: false, description: 'number limit of hottest reports'

      def resolve(ident:, level: nil, limit: 5)
        resp = BaseCollection.hottest(ident, level, limit: limit)
        list = resp&.[]('hits')&.[]('hits')
        candidates = []
        if list.present?
          list.each do |item|
            level = item['_source']['level']
            label = item['_source']['label']
            updated_at = item['_source']['updated_at']
            candidates << OpenStruct.new({label: label, level: level, status: 'success', updated_at: updated_at})
          end
        end
        candidates
      end
    end
  end
end
