# frozen_string_literal: true

module Types
  module Queries
    class CommunityMetricQuery < BaseQuery
      type [Types::CommunityMetricType], null: false
      description 'Get community metrics data of compass'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', begin_date: nil, end_date: nil)
        label = normalize_label(label)

        current_user = context[:current_user]
        if RESTRICTED_LABEL_LIST.include?(label) && !RESTRICTED_LABEL_VIEWERS.include?(current_user&.id.to_s)
          raise GraphQL::ExecutionError.new I18n.t('users.forbidden')
        end

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        limit = level == 'repo' ? 60 : 120

        if !interval
          resp = CommunityMetric.query_repo_by_date(label, begin_date, end_date, page: 1, per: limit)

          build_metrics_data(resp, Types::CommunityMetricType) do |skeleton, raw|
            skeleton['short_code'] = ShortenedLabel.convert(raw['label'], raw['level'])
            OpenStruct.new(skeleton.merge(raw))
          end
        else
          aggs = generate_interval_aggs(Types::CommunityMetricType, :grimoire_creation_date, interval)
          resp = CommunityMetric.aggs_repo_by_date(label, begin_date, end_date, aggs)

          build_metrics_data(resp, Types::CommunityMetricType) do |skeleton, raw|
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
