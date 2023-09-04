# frozen_string_literal: true

module Types
  module Queries
    class CodequalityMetricQuery < BaseQuery
      type [Types::CodequalityMetricType], null: false
      description 'Get code quality metrics data of compass'
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
          resp = CodequalityMetric.query_repo_by_date(label, begin_date, end_date, page: 1, per: limit)

          build_metrics_data(resp, Types::CodequalityMetricType) do |skeleton, raw|
            skeleton.merge!(raw)
            CodequalityMetric.fields_aliases.map { |alias_key, key| skeleton[alias_key] = raw[key] }
            CodequalityMetric.calc_fields.map do |key, sources|
              skeleton[key] = (raw[sources[0]].to_f * raw[sources[1]] rescue 0)
            end
            OpenStruct.new(skeleton)
          end
        else
          aggs = generate_interval_aggs(
            Types::CodequalityMetricType,
            :grimoire_creation_date,
            interval,
            'Float',
            CodequalityMetric.fields_aliases
          )
          resp = CodequalityMetric.aggs_repo_by_date(label, begin_date, end_date, aggs)

          build_metrics_data(resp, Types::CodequalityMetricType) do |skeleton, raw|
            data = raw[:data]
            template = raw[:template]
            skeleton.keys.map do |k|
              key = k.to_s.underscore
              skeleton[key] = data&.[](key)&.[]('value') || template[key]
            end
            pr_count = data&.[]('pr_count')&.[]('value').to_f
            CodequalityMetric.calc_fields.map do |key, sources|
              skeleton[key] = (data&.[](sources[0])&.[]('value').to_f * pr_count rescue 0)
            end
            skeleton['grimoire_creation_date'] =
              DateTime.parse(data&.[]('key_as_string')).strftime rescue data&.[]('key_as_string')
            OpenStruct.new(skeleton)
          end
        end
      end
    end
  end
end
