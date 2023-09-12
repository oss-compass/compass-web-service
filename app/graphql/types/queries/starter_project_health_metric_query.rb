# frozen_string_literal: true

module Types
  module Queries
    class StarterProjectHealthMetricQuery < BaseQuery
      type [Types::StarterProjectHealthMetricType], null: false
      description 'Get starter project health metrics data of compass'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', begin_date: nil, end_date: nil)
        label = normalize_label(label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        if !interval
          resp = StarterProjectHealthMetric.query_repo_by_date(label, begin_date, end_date, page: 1)

          build_metrics_data(resp, Types::StarterProjectHealthMetricType) do |skeleton, raw|
            skeleton.merge!(raw)
            StarterProjectHealthMetric.fields_aliases.map { |alias_key, key| skeleton[alias_key] = raw[key] }
            skeleton['short_code'] = ShortenedLabel.convert(skeleton['label'], skeleton['level'])
            OpenStruct.new(skeleton)
          end
        else
          aggs = generate_interval_aggs(
            Types::StarterProjectHealthMetricType,
            :grimoire_creation_date,
            interval,
            'Float',
            StarterProjectHealthMetric.fields_aliases
          )
          resp = StarterProjectHealthMetric.aggs_repo_by_date(label, begin_date, end_date, aggs)

          build_metrics_data(resp, Types::StarterProjectHealthMetricType) do |skeleton, raw|
            data = raw[:data]
            template = raw[:template]
            skeleton.keys.map do |k|
              key = k.to_s.underscore
              skeleton[key] = data&.[](key)&.[]('value') || template[key]
            end
            skeleton['short_code'] = ShortenedLabel.convert(skeleton['label'], skeleton['level'])
            skeleton['grimoire_creation_date'] =
              DateTime.parse(data&.[]('key_as_string')).strftime rescue data&.[]('key_as_string')
            OpenStruct.new(skeleton)
          end
        end
      end
    end
  end
end
