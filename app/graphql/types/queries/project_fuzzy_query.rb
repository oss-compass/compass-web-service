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
        prefix = keyword
        keyword = keyword.gsub(/^https:\/\//, '')
        keyword = keyword.gsub(/^http:\/\//, '')
        keyword = keyword.gsub(/[^0-9a-zA-Z_\-\. ]/i, '')
        return [] if keyword.chop.blank?
        resp =
          ActivityMetric
            .fuzzy_search(
              keyword.gsub('/', ' '),
              'label',
              'label.keyword',
              fields: fields,
              filters: { level: level }
            )
        fuzzy_list = resp&.[]('hits')&.[]('hits')

        resp =
          ActivityMetric
            .prefix_search(
              prefix,
              'label.keyword',
              'label.keyword',
              fields: fields,
              filters: { level: level }
            )
        prefix_list = resp&.[]('hits')&.[]('hits')

        existed, candidates = {}, []
        [fuzzy_list, prefix_list].each do |list|
          if list.present?
            list.flat_map do |items|
              items['inner_hits']['by_level']['hits']['hits'].map do |item|
                metadata__enriched_on = item['_source']['metadata__enriched_on']
                updated_at = DateTime.parse(metadata__enriched_on).strftime rescue metadata__enriched_on
                candidate = OpenStruct.new(
                  item['_source']
                    .slice(*fields)
                    .merge(
                      {
                        status: ProjectTask::Success,
                        updated_at: updated_at,
                        short_code: ShortenedLabel.convert(item['_source']['label'], item['_source']['level']),
                        collections: BaseCollection.collections_of(item['_source']['label'], level: item['_source']['level'])
                      }
                    )
                )
                unless existed[candidate.label]
                  existed[candidate.label] = true
                  candidates << candidate
                end
              end
            end
          end
        end

        ProjectTask.where('project_name LIKE ?', "%#{keyword}")
          .yield_self do |can|
          level.present? ? can.where(level: level) : can
        end.limit(5).map do |item|
          unless existed[item.project_name]
            candidates << {
              level: item.level,
              label: item.project_name,
              status: item.status,
              updated_at: item.updated_at,
              short_code: ShortenedLabel.convert(item.project_name, item.level),
              collections: BaseCollection.collections_of(item.project_name, level: item.level)
            }
          end
        end

        candidates
      end
    end
  end
end
