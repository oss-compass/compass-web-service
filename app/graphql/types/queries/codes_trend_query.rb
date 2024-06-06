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
        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        subjects = Subject.get_subject_sig_by_label(label, level)

        filter_range_times = (0..14).map { |i|
          times_interval = (end_date - begin_date) / 15
          { from: Time.parse("1970-01-01"), to: begin_date + (i + 1) * times_interval }
        }
        aggs = {
          date_ranges: {
            range: { field: "grimoire_creation_date", ranges: filter_range_times },
            aggs: {
              lines_changed: { sum: { field: "lines_changed" } },
              lines_added: { sum: { field: "lines_added" } },
              lines_removed: { sum: { field: "lines_removed" } },
              lines_total: { bucket_script: { buckets_path: { linesAdded: "lines_added", linesRemoved: "lines_removed" },
                                              script: "params.linesAdded - params.linesRemoved" } }
            }
          }
        }

        result_list = []
        subjects.map do |subject|
          indexer, repo_urls = select_idx_repos_by_lablel_and_level(subject.label, subject.level, GiteeGitEnrich, GithubGitEnrich)
          resp = indexer.aggs_repo_by_by_repo_urls(repo_urls, begin_date, end_date, branch: branch, aggs: aggs)
          buckets = resp&.[]('aggregations')&.[]('date_ranges')&.[]('buckets') || []
          detail_list = buckets.map do |data|
            skeleton = Hash[Types::CodeTrendDetailType.fields.keys.map(&:underscore).zip([])].symbolize_keys
            skeleton[:date] = data['to_as_string']
            skeleton[:count] = [data.dig('lines_total', 'value'), 0].compact.max
            skeleton
          end
          result_list.push({sig_name: subject.sig_name, detail_list: detail_list})
        end
        result_list
      end
    end
  end
end
