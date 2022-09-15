# frozen_string_literal: true

module Types
  module Queries
    class ActivityMetricQuery < BaseQuery
      type [Types::ActivityMetricType], null: false
      description 'Get activity metrics data of compass'
      argument :url, String, required: true, description: 'repo or project url'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(url: nil, level: 'repo', begin_date: nil, end_date: nil)
        uri = Addressable::URI.parse(url)
        repo_url = "#{uri&.scheme}://#{uri&.normalized_host}#{uri&.path}"

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        if !interval
          resp = ActivityMetric.query_repo_by_date(repo_url, begin_date, end_date)

          build_metrics_data(resp, Types::ActivityMetricType) do |skeleton, raw|
            skeleton.merge!(raw)
            skeleton['active_c1_pr_create_contributor_count'] = raw['active_C1_pr_create_contributor']
            skeleton['active_c2_contributor_count'] = raw['active_C2_contributor_count']
            skeleton['active_c1_pr_comments_contributor_count'] = raw['active_C1_pr_comments_contributor']
            skeleton['active_c1_issue_create_contributor_count'] = raw['active_C1_issue_create_contributor']
            skeleton['active_c1_issue_comments_contributor_count'] = raw['active_C1_issue_comments_contributor']
            OpenStruct.new(skeleton)
          end
        else
          aggs = generate_interval_aggs(
            Types::ActivityMetricType,
            :grimoire_creation_date,
            interval,
            'Float',
            {
              'active_c1_pr_create_contributor_count' => 'active_C1_pr_create_contributor',
              'active_c2_contributor_count' => 'active_C2_contributor_count',
              'active_c1_pr_comments_contributor_count' => 'active_C1_pr_comments_contributor',
              'active_c1_issue_create_contributor_count' => 'active_C1_issue_create_contributor',
              'active_c1_issue_comments_contributor_count' => 'active_C1_issue_comments_contributor'
            })
          resp = ActivityMetric.aggs_repo_by_date(repo_url, begin_date, end_date, aggs)

          build_metrics_data(resp, Types::ActivityMetricType) do |skeleton, raw|
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
