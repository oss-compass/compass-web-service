# frozen_string_literal: true

module Types
  module Queries
    class ActivitySummaryQuery < BaseQuery
      type [Types::ActivitySummaryType], null: false
      description 'Get activity summary data of compass'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(begin_date: nil, end_date: nil)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        if !interval
          resp = ActivitySummary.query_by_date(begin_date, end_date)
          build_metrics_data(
            resp,
            Types::ActivitySummaryType,
          ) do |skeleton, raw|
            stats = Types::MetricStatType.fields.keys
            fields = skeleton.keys
            fields.map do |key|
              skeleton[key] = OpenStruct.new({ mean: raw["#{key}_mean"], median: raw["#{key}_median"] })
            end
            ActivityMetric.fields_aliases.map do |alias_key, key|
              skeleton[alias_key] = OpenStruct.new({ mean: raw["#{key}_mean"], median: raw["#{key}_median"] })
            end
            skeleton['grimoire_creation_date'] = raw['grimoire_creation_date']
            OpenStruct.new(skeleton)
          end
        else
          aggs = generate_interval_aggs(
            Types::ActivitySummaryType,
            :grimoire_creation_date,
            interval,
            'StatType',
            ActivityMetric.fields_aliases,
            ['_median', '_mean']
          )
          resp = ActivitySummary.aggs_by_date(begin_date, end_date, aggs)

          build_metrics_data(resp, Types::ActivitySummaryType) do |skeleton, raw|
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
end
