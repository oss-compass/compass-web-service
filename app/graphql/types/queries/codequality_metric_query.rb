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
        label =
          if label =~ URI::regexp
            uri = Addressable::URI.parse(label)
            label = "#{uri&.scheme}://#{uri&.normalized_host}#{uri&.path}"
          else
            label
          end

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        if !interval
          resp = CodequalityMetric.query_repo_by_date(label, begin_date, end_date)

          build_metrics_data(resp, Types::CodequalityMetricType) do |skeleton, raw|
            skeleton.merge!(raw)
            skeleton['loc_frequency'] = raw['LOC_frequency']
            skeleton['active_c1_pr_create_contributor_count'] = raw['active_C1_pr_create_contributor']
            skeleton['active_c1_pr_comments_contributor_count'] = raw['active_C1_pr_comments_contributor']
            skeleton['active_c2_contributor_count'] = raw['active_C2_contributor_count']
            OpenStruct.new(skeleton)
          end
        else
          aggs = generate_interval_aggs(
            Types::CodequalityMetricType,
            :grimoire_creation_date,
            interval,
            'Float',
            {
              'loc_frequency' => 'LOC_frequency',
              'active_c1_pr_create_contributor_count' => 'active_C1_pr_create_contributor',
              'active_c2_contributor_count' => 'active_C2_contributor_count',
              'active_c1_pr_comments_contributor_count' => 'active_C1_pr_comments_contributor',
            }
          )
          resp = CodequalityMetric.aggs_repo_by_date(label, begin_date, end_date, aggs)

          build_metrics_data(resp, Types::CodequalityMetricType) do |skeleton, raw|
            data = raw[:data]
            template = raw[:template]
            skeleton.keys.map do |k|
              key = k.to_s.underscore
              skeleton[key] = data&.[](key)&.[]('value') || template[key]
            end
            skeleton['grimoire_creation_date'] = data&.[]('key_as_string')
            OpenStruct.new(skeleton)
          end
        end
      end
    end
  end
end
