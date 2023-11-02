# frozen_string_literal: true

module Types
  module Queries
    class CommunityMetricQuery < BaseQuery
      type [Types::CommunityMetricType], null: false
      description 'Get community metrics data of compass'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :repo_type, String, required: false, description: 'repo type, for repo level default: null and community level default: software-artifact'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', repo_type: nil, begin_date: nil, end_date: nil)
        label = normalize_label(label)

        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        repo_type = level == 'repo' ? nil : repo_type || 'software-artifact'

        if !interval
          resp = CommunityMetric.query_repo_by_date(label, begin_date, end_date, page: 1, type: repo_type)

          build_metrics_data(resp, Types::CommunityMetricType) do |skeleton, raw|
            skeleton['short_code'] = ShortenedLabel.convert(raw['label'], raw['level'])
            OpenStruct.new(skeleton.merge(raw))
          end
        else
          aggs = generate_interval_aggs(Types::CommunityMetricType, :grimoire_creation_date, interval)
          resp = CommunityMetric.aggs_repo_by_date(label, begin_date, end_date, aggs, type: repo_type)

          build_metrics_data(resp, Types::CommunityMetricType) do |skeleton, raw|
            data = raw[:data]
            template = raw[:template]
            skeleton.keys.map do |k|
              key = k.to_s.underscore
              skeleton[key] = data.key?(key) ?  data[key]&.[]('value') : template[key]
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
