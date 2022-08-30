# frozen_string_literal: true

module Types
  module Queries
    class ActivityMetricQuery < BaseQuery
      type [Types::ActivityMetricType], null: false
      description 'Get activity metrics data of compass'
      argument :url, String, required: true, description: 'repo or project url'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :range, String, required: false, description: 'time range (3m 6m 1y 2y 3y 5y 10y s2000)' ,  default_value: '3m'
      def resolve(url: nil, level: 'repo', range: '3m')
        uri = Addressable::URI.parse(url)
        repo_url = "#{uri&.scheme}://#{uri&.normalized_host}#{uri&.path}"

        begin_date, end_date = extract_date(range)

        if (end_date - begin_date).to_i < 365
          resp =
            ActivityMetric
              .must(match_phrase: { label: repo_url })
              .page(1)
              .per(30)
              .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
              .execute
              .raw_response
          build_metrics_data(resp, Types::ActivityMetricType) do |skeleton, raw|
            OpenStruct.new(skeleton.merge(raw))
          end
        else
          metric_fields = [
            :activity_score,
            :closed_issues_count,
            :code_review_count,
            :comment_frequency,
            :commit_frequency,
            :contributor_count,
            :created_since,
            :updated_issues_count,
            :updated_since
          ]
          interval_str = (end_date - begin_date).to_i < (3 * 365) ? '1M' : '1q'
          aggs = generate_interval_aggs(
            :grimoire_creation_date,
            interval_str,
            metric_fields
          )
          resp =
            ActivityMetric
              .must(match_phrase: { label: repo_url })
              .page(1)
              .per(1)
              .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
              .aggregate(aggs)
              .execute
              .raw_response
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
