# frozen_string_literal: true

module Types
  module Queries
    class SubjectSigActivityMetricQuery < BaseQuery
      type [Types::SubjectSigMetricType], null: false
      description 'Get community sig activity metrics data of compass'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', begin_date: nil, end_date: nil)
        label = ShortenedLabel.normalize_label(label)
        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        repo_type = "software-artifact"

        subjects = Subject.get_subject_sig_by_label(label, level)

        filter_range_times = []
        current_month = Date.new(begin_date.year, begin_date.month, 1)
        while current_month < end_date
          next_month = current_month.next_month
          interval_end = [next_month - 1, end_date].min
          filter_range_times << { from: current_month, to: interval_end }
          current_month = next_month
        end
        aggs = {
          date_ranges: {
            range: { field: "grimoire_creation_date", ranges: filter_range_times },
            aggs: {
              avg_score: { avg: { field: ActivityMetric.main_score } }
            }
          }
        }

        result_list = []
        subjects.map do |subject|
          resp = ActivityMetric.aggs_repo_by_date(subject.label, begin_date, end_date, aggs, type: repo_type)
          buckets = resp&.[]('aggregations')&.[]('date_ranges')&.[]('buckets') || []
          detail_list = buckets.map do |data|
            skeleton = Hash[Types::SubjectSigMetricDetailType.fields.keys.map(&:underscore).zip([])].symbolize_keys
            skeleton[:date] = data['from_as_string']
            skeleton[:score] = [data.dig('avg_score', 'value'), 0].compact.max.round(4)
            skeleton
          end
          result_list.push({
                             sig_name: subject.sig_name,
                             label: subject.label,
                             level: subject.level,
                             detail_list: detail_list
                           })

        end
        result_list
      end
    end
  end
end
