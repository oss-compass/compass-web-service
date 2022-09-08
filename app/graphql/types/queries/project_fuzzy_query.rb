# frozen_string_literal: true


module Types
  module Queries
    class ProjectFuzzyQuery < BaseQuery
      type [String], null: false
      description 'Fuzzy search project by keyword'
      argument :keyword, String, required: true, description: 'repo or project keyword'

      def resolve(keyword: nil)
        resp =
          ActivityMetric
            .fuzzy_search(keyword.gsub('/', ' '), 'label', agg_field: 'label.keyword')
        list = resp&.[]('aggregations')&.[]('label.keyword')&.[]('buckets')
        list.present? ? list.map { |item| item['key'] } : []
      end
    end
  end
end
