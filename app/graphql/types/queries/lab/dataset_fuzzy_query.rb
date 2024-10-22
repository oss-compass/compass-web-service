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

          resp =
            BaseCollection
              .fuzzy_search(
                keyword.gsub('/', ' '),
                'label',
                'label.keyword',
              )
          fuzzy_list = resp&.[]('hits')&.[]('hits')

          if fuzzy_list.nil? || fuzzy_list.empty?
            resp =
              ActivityMetric
                .fuzzy_search(
                  keyword.gsub('/', ' '),
                  'label',
                  'label.keyword',
                )
            fuzzy_list = resp&.[]('hits')&.[]('hits')
          end

          resp =
            BaseCollection
              .prefix_search(
                prefix,
                'label.keyword',
                'label.keyword',
              )
          prefix_list = resp&.[]('hits')&.[]('hits')

          candidates = []

          [fuzzy_list, prefix_list].each do |list|
            list.flat_map do |item|
              item = item['_source']
              if item.present?
                candidates << {
                  first_ident: item['first_collection'],
                  second_ident: item['collection'],
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
