# frozen_string_literal: true


module Types
  module Queries
    class ProjectFuzzyQuery < BaseQuery
      type [ProjectCompletionRowType], null: false
      description 'Fuzzy search project by keyword'
      argument :keyword, String, required: true, description: 'repo or project keyword'
      argument :level, String, required: false, description: 'filter by level (repo/project)'

      def resolve(keyword: nil, level: nil)
        fields = ['label', 'level']
        resp =
          ActivityMetric
            .fuzzy_search(
              keyword.gsub('/', ''),
              'label',
              'label.keyword',
              fields: fields,
              filters: { level: level }
            )
        list = resp&.[]('hits')&.[]('hits')

        list.present? ?
          list.map do |item|
            OpenStruct.new(item['_source'].slice(*fields))
          end :
          ProjectTask.where('project_name LIKE ?', "#{keyword}%").limit(5).map do |item|
            OpenStruct.new({level: item.level, label: item.project_name})
          end
      end
    end
  end
end
