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

        now = Date.today

        end_date = Date.tomorrow

        begin_date =
          case range.to_s.downcase
          when '3m'
            now - 3.months
          when '6m'
            now - 6.months
          when '1y'
            now - 1.year
          when '2y'
            now - 2.years
          when '3y'
            now - 3.years
          when '5y'
            now - 5.years
          when '10y'
            now - 10.years
          else
            Date.new(2000)
          end

        resp =
          ActivityMetric
            .must(match: { label: repo_url })
            .range(:grimoire_creation_date, gt: begin_date, lt: end_date)
            .execute
            .raw_response

        build_metrics_data(resp, Types::ActivityMetricType) do |skeleton, raw|
          OpenStruct.new(skeleton.merge(raw))
        end
      end
    end
  end
end
