# frozen_string_literal: true


module Types
  module Queries
    class ProjectFuzzyQuery < BaseQuery
      type [ProjectCompletionRowType], null: false
      description 'Fuzzy search project by keyword'
      argument :keyword, String, required: true, description: 'repo or project keyword'

      def resolve(keyword: nil)
        fields = ['label', 'level']
        resp =
          ActivityMetric
            .fuzzy_search(keyword.gsub('/', ' '), 'label', 'label.keyword', fields: fields)
        list = resp&.[]('hits')&.[]('hits')
        list.present? ? list.map { |item| OpenStruct.new(item['_source'].slice(*fields)) } : []
      end
    end
  end
end
