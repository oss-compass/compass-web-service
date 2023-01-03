# frozen_string_literal: true

module Types
  module Queries
    class CodequalitySummaryQuery < BaseQuery
      type [Types::CodequalitySummaryType], null: false
      description 'Get codequality summary data of compass'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(begin_date: nil, end_date: nil)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        if !interval
          resp = CodequalitySummary.query_by_date(begin_date, end_date)
          build_metrics_data(resp, Types::CodequalitySummaryType) do |skeleton, raw|
            stats = Types::MetricStatType.fields.keys
            fields = skeleton.keys
            fields.map do |key|
              skeleton[key] =
                OpenStruct.new({ mean: raw["#{key}_mean"], median: raw["#{key}_median"] })
            end
            CodequalityMetric.fields_aliases.map do |alias_key, key|
              skeleton[alias_key] =
                OpenStruct.new({ mean: raw["#{key}_mean"], median: raw["#{key}_median"] })
            end
            CodequalityMetric.calc_fields.map do |key, sources|
              skeleton[key] =
                OpenStruct.new(
                  {
                    mean: (raw["#{sources[0]}_mean"].to_f * raw["#{sources[1]}_mean"] rescue 0),
                    median: (raw["#{sources[0]}_median"].to_f * raw["#{sources[1]}_median"] rescue 0)
                  }
                )
            end
            skeleton['grimoire_creation_date'] =
              DateTime.parse(raw['grimoire_creation_date']) rescue raw['grimoire_creation_date']

            OpenStruct.new(skeleton)
          end
        else
          aggs = generate_interval_aggs(
            Types::CodequalitySummaryType,
            :grimoire_creation_date,
            interval,
            'StatType',
            CodequalityMetric.fields_aliases,
            ['_median', '_mean']
          )
          resp = CodequalitySummary.aggs_by_date(begin_date, end_date, aggs)

          build_metrics_data(resp, Types::CodequalitySummaryType) do |skeleton, raw|
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
            CodequalityMetric.calc_fields.map do |key, sources|
              skeleton[key] =
                OpenStruct.new(
                  {
                    mean: (data&.[]("#{sources[0]}_mean")&.[]('value').to_f * data&.[]("#{sources[1]}_mean")&.[]('value') rescue 0),
                    median: (data&.[]("#{sources[0]}_median")&.[]('value').to_f * data&.[]("#{sources[1]}_median")&.[]('value') rescue 0)
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
