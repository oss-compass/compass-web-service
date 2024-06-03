# frozen_string_literal: true

module Types
  module Queries
    class CodesTrendQuery < BaseQuery
      type [Types::CodeTrendType], null: false
      description 'Get code trend data'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :branch, String, required: false, description: 'commit branch', default_value: 'master'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', branch: 'master', begin_date: nil, end_date: nil)
        label = ShortenedLabel.normalize_label(label)
        login_required!(context[:current_user])

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        indexer, repo_urls =
          select_idx_repos_by_lablel_and_level(label, level, GiteeGitEnrich, GithubGitEnrich)

        repo_sig_list = SubjectSig.fetch_subject_sig_list_by_repo_urls(label, level, repo_urls)
        map_repo_sig = repo_sig_list.group_by { |item| item[:sig_name] }
                                  .transform_values { |items| items.map { |item| item[:label] } }
        filter_range_times = (0..14).map { |i|
          times_interval = (end_date - begin_date) / 15
          { from: Time.parse("1970-01-01"), to: begin_date + (i + 1) * times_interval }
        }
        result_list = []
        map_repo_sig.each do |key, value|
          resp = indexer.code_line_trend_by_repo_urls(value, begin_date, end_date, branch, filter_range_times)
          buckets = resp&.[]('aggregations')&.[]('date_ranges')&.[]('buckets') || []
          detail_list = buckets.map do |data|
            skeleton = Hash[Types::CodeTrendDetailType.fields.keys.map(&:underscore).zip([])].symbolize_keys
            skeleton[:date] = data['to_as_string']
            skeleton[:count] = [data.dig('lines_total', 'value'), 0].compact.max
            skeleton
          end
          result_list.push({sig_name: key, detail_list: detail_list})
        end
        result_list
      end
    end
  end
end
