# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class DatasetFuzzyQuery < BaseQuery
        type [DatasetCompletionRowType], null: true
        argument :keyword, String, required: true, description: 'repo or project keyword'
        description 'Fuzzy search dataset by keyword'

        def resolve(keyword: nil)
          current_user = context[:current_user]

          login_required!(current_user)

          prefix = keyword
          keyword = keyword.gsub(/^https:\/\//, '')
          keyword = keyword.gsub(/^http:\/\//, '')
          keyword = keyword.gsub(/[^0-9a-zA-Z_\-\. ]/i, '')
          fields = ['label', 'level']

          resp =
            BaseCollection
              .fuzzy_search(
                keyword.gsub('/', ' '),
                'label',
                'label.keyword',
              )
          fuzzy_list = resp&.[]('hits')&.[]('hits')

          resp_home =
            ActivityMetric
              .fuzzy_search(
                keyword.gsub('/', ' '),
                'label',
                'label.keyword',
              )
          fuzzy_home_list = resp_home&.[]('hits')&.[]('hits')

          resp =
            ActivityMetric
              .prefix_search(
                prefix,
                'label.keyword',
                'label.keyword',
                fields: fields
              )
          prefix_home_list = resp&.[]('hits')&.[]('hits')
          combined_list = (fuzzy_list + fuzzy_home_list + prefix_home_list)
          fuzzy_list = combined_list.uniq { |item| item['_source']['label'] }

          resp =
            BaseCollection
              .prefix_search(
                prefix,
                'label.keyword',
                'label.keyword',
              )
          prefix_list = resp&.[]('hits')&.[]('hits')
          prefix_list = prefix_list.uniq { |item| item['_source']['label'] }

          candidates = []

          [fuzzy_list, prefix_list].each do |list|
            list.flat_map do |item|
              item = item['_source']
              if item.present?
                candidates << {
                  first_ident: item['first_collection'].presence || 'Other',
                  second_ident: item['collection'].presence || 'Other',
                  label: item['label'],
                  level: item['level'],
                  short_code: ShortenedLabel.convert(item['label'], item['level'])
                }
              end
            end
          end

          Set.new(candidates)
        end
      end
    end
  end
end
