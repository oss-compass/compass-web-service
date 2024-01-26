# frozen_string_literal: true

module Types
  module Queries
    class OrgFuzzyQuery < BaseQuery
      type [OrgCompletionRowType], null: false
      description 'Fuzzy search organization by keyword'
      argument :keyword, String, required: true, description: 'organization keyword'

      def resolve(keyword: nil)
        prefix = keyword
        keyword = keyword.gsub(/^https:\/\//, '')
        keyword = keyword.gsub(/^http:\/\//, '')
        keyword = keyword.gsub(/[^0-9a-zA-Z_\-\. ]/i, '')
        return [] if keyword.chop.blank?

        resp =
          Organization
            .fuzzy_search(
              keyword.gsub('/', ' '),
              'org_name',
              'org_name.keyword',
            )
        fuzzy_list = resp&.[]('hits')&.[]('hits')

        resp =
          Organization
            .prefix_search(
              prefix,
              'org_name.keyword',
              'org_name.keyword',
            )
        prefix_list = resp&.[]('hits')&.[]('hits')

        candidates = []

        [fuzzy_list, prefix_list].each do |list|
          list.flat_map do |item|
            item = item['_source']
            if item.present?
              candidates << item.slice('org_name')
            end
          end
        end

        Set.new(candidates)
      end
    end
  end
end
