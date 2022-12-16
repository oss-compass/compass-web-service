# frozen_string_literal: true

module Types
  module Queries
    class ActivityMetricQuery < BaseQuery
      type [Types::ActivityMetricType], null: false
      description 'Get activity metrics data of compass'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', begin_date: nil, end_date: nil)
        label = normalize_label(label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        if !interval
          resp = ActivityMetric.query_repo_by_date(label, begin_date, end_date)

          build_metrics_data(resp, Types::ActivityMetricType) do |skeleton, raw|
            skeleton.merge!(raw)
            ActivityMetric.fields_aliases.map { |alias_key, key| skeleton[alias_key] = raw[key] }
            OpenStruct.new(skeleton)
          end
        else
          aggs = generate_interval_aggs(
            Types::ActivityMetricType,
            :grimoire_creation_date,
            interval,
            'Float',
            ActivityMetric.fields_aliases
          )
          resp = ActivityMetric.aggs_repo_by_date(label, begin_date, end_date, aggs)

          build_metrics_data(resp, Types::ActivityMetricType) do |skeleton, raw|
            data = raw[:data]
            template = raw[:template]
            skeleton.keys.map do |k|
              key = k.to_s.underscore
              skeleton[key] = data&.[](key)&.[]('value') || template[key]
            end
            skeleton['grimoire_creation_date'] = DateTime.parse(data&.[]('key_as_string')).strftime rescue data&.[]('key_as_string')
            OpenStruct.new(skeleton)
          end
        end
      end
    end
  end
end
