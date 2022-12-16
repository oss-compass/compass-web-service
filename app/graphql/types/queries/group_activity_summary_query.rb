# frozen_string_literal: true

module Types
  module Queries
    class GroupActivitySummaryQuery < BaseQuery
      type [Types::GroupActivitySummaryType], null: false
      description 'Get group activity summary data of compass'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(begin_date: nil, end_date: nil)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        interval = '1w' if !interval

        aggs = generate_interval_aggs(
          Types::GroupActivitySummaryType,
          :grimoire_creation_date,
          interval,
          'StatType',
          GroupActivityMetric.fields_aliases,
          ['_median', '_mean']
        )

        resp = GroupActivitySummary.aggs_by_date(begin_date, end_date, aggs)

        build_metrics_data(resp, Types::GroupActivitySummaryType) do |skeleton, raw|
          data = raw[:data]
          template = raw[:template]
          skeleton.keys.map do |k|
            key = k.to_s.underscore
            skeleton[key] =
              OpenStruct.new(
                {
                  mean: data&.[]("#{key}_mean")&.[]('value') || template["#{key}_mean"],
                  median: data&.[]("#{key}_median")&.[]('value') || template["#{key}_median"]
                }
              )
          end
          skeleton['grimoire_creation_date'] = DateTime.parse(data&.[]('key_as_string')).strftime rescue data&.[]('key_as_string')
          OpenStruct.new(skeleton)
        end
      end
    end
  end
end
