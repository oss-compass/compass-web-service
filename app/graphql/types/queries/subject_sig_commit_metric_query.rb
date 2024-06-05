# frozen_string_literal: true

module Types
  module Queries
    class SubjectSigCommitMetricQuery < BaseQuery
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
              count_hash: { cardinality: { field: "hash" } }
            }
          }
        }

        result_list = []
        subjects.map do |subject|
          indexer, repo_urls = select_idx_repos_by_lablel_and_level(subject.label, subject.level, GiteeGitEnrich, GithubGitEnrich)
          resp = indexer.aggs_repo_by_by_repo_urls(repo_urls, begin_date, end_date, aggs: aggs)
          buckets = resp&.[]('aggregations')&.[]('date_ranges')&.[]('buckets') || []
          detail_list = buckets.map do |data|
            skeleton = Hash[Types::SubjectSigMetricDetailType.fields.keys.map(&:underscore).zip([])].symbolize_keys
            skeleton[:date] = data['from_as_string']
            skeleton[:score] = [data.dig('count_hash', 'value'), 0].compact.max
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
