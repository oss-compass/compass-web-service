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
        keyword.gsub!(/^https:\/\//, '')
        keyword.gsub!(/^http:\/\//, '')
        resp =
          ActivityMetric
            .fuzzy_search(
              keyword,
              'label',
              'label.keyword',
              fields: fields,
              filters: { level: level }
            )
        list = resp&.[]('hits')&.[]('hits')

        existed, candidates = {}, []
        if list.present?
          list.flat_map do |items|
            items['inner_hits']['by_level']['hits']['hits'].map do |item|
              candidate = OpenStruct.new(item['_source'].slice(*fields).merge({status: 'success'}))
              existed[candidate.label] = true
              candidates << candidate
            end
          end
        end

        ProjectTask.where('project_name LIKE ?', "%#{keyword}")
          .yield_self do |can|
          level.present? ? can.where(level: level) : can
        end.limit(5).map do |item|
          unless existed[item.project_name]
            candidates << OpenStruct.new({level: item.level, label: item.project_name, status: item.status})
          end
        end

        candidates
      end
    end
  end
end
