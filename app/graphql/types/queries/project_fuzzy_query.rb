# frozen_string_literal: true

module Types
  module Queries
    class ProjectFuzzyQuery < BaseQuery
      type [ProjectCompletionRowType], null: false
      description 'Fuzzy search project by keyword'
      argument :keyword, String, required: true, description: 'repo or project keyword'
      argument :level, String, required: false, description: 'filter by level (repo/project)'
      argument :type, Integer, required: false, description: '1 developer, 2 repo , 3 both'

      def resolve(keyword: nil, level: nil, type: nil)
        fields = ['label', 'level']
        prefix = keyword
        keyword = keyword.gsub(/^https:\/\//, '')
        keyword = keyword.gsub(/^http:\/\//, '')
        keyword = keyword.gsub(/[^0-9a-zA-Z_\-\. ]/i, '')
        return [] if keyword.chop.blank?

        if type == 1 # developer
          return search_developers(prefix)
        elsif type == 2 # repo
          return search_repos(keyword, level, fields, prefix)
        elsif type ==3
          # 分别获取最多8个仓库和8个开发者
          repos = search_repos(keyword, level, fields, prefix)
          devs = search_developers(prefix)
          # 合并结果
          repos + devs
        else
          # developers = search_developers(keyword, level)
          # repos = search_repos(keyword, level, fields, prefix)
          # return (developers + repos).uniq { |item| item[:label] }
           return search_repos(keyword, level, fields, prefix)
        end
      end

      private

      def search_developers(keyword)
        candidates = []
        event_indexer = GithubEventContributor
        resp = event_indexer.fuzz_query(keyword)
        resp_list = resp&.[]('hits')&.[]('hits')

        resp_list.each do |item|
          source = item['_source']
          developer = OpenStruct.new(
            label: source['avatar_url'],
            level: source['html_url'],
            status: '',
            short_code:'',
            collections:[],
            type: 'developer'
            )
          candidates << developer
        end

        candidates.take(8)
      end

      def search_repos(keyword, level, fields, prefix)
        es_filters = { level: level }

        fuzzy_resp = ActivityMetric.fuzzy_search(
          keyword.gsub('/', ' '),
          'label',
          'label.keyword',
          fields: fields,
          filters: es_filters
        )
        fuzzy_list = fuzzy_resp&.[]('hits')&.[]('hits')


        prefix_resp = ActivityMetric.prefix_search(
          prefix,
          'label.keyword',
          'label.keyword',
          fields: fields,
          filters: es_filters
        )
        prefix_list = prefix_resp&.[]('hits')&.[]('hits')

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
              collections: BaseCollection.collections_of(item.project_name, level: item.level),
              type: 'repo'
            }
          end
        end

        candidates.take(8)
      end
    end
  end
end
