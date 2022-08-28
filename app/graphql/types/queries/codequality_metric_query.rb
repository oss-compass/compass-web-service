# frozen_string_literal: true

module Types
  module Queries
    class CodequalityMetricQuery < BaseQuery
      type [Types::CodequalityMetricType], null: false
      description 'Get code quality metrics data of compass'
      argument :url, String, required: true, description: 'repo or project url'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :range, String, required: false, description: 'time range (3m 6m 1y 2y 3y 5y 10y s2000)' ,  default_value: '3m'
      def resolve(url: nil, level: 'repo', range: '3m')
        uri = Addressable::URI.parse(url)
        repo_url = "#{uri&.scheme}://#{uri&.normalized_host}#{uri&.path}"

        begin_date, end_date = extract_date(range)

        resp =
          CodequalityMetric
            .must(match: { label: repo_url })
            .range(:grimoire_creation_date, gt: begin_date, lt: end_date)
            .execute
            .raw_response

        build_metrics_data(resp, Types::CodequalityMetricType) do |skeleton, raw|
          skeleton.merge!(raw)
          skeleton['loc_frequency'] = raw['LOC_frequency']
          OpenStruct.new(skeleton)
        end
      end
    end
  end
end
