# frozen_string_literal: true

module Types
  module Queries
    class IssuesDetailOverviewQuery < BaseQuery

      attr_accessor :indexer, :repo_urls, :begin_date, :end_date

      type Types::Meta::IssueDetailOverviewType, null: false
      description 'Get overview data of a issue detail'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'

      def resolve(label: nil, level: 'repo')
        label = normalize_label(label)

        validate_by_label!(context[:current_user], label)

        @begin_date, @end_date, interval = extract_date(nil, nil)

        @indexer, @repo_urls =
                  select_idx_repos_by_lablel_and_level(
                    label,
                    level,
                    GiteeIssueEnrich,
                    GithubIssueEnrich
                  )

        issue_base =
          indexer
            .where(pull_request: false)
            .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
            .must(terms: { tag: repo_urls })

        count = issue_base.total_entries

        closed_issue_count =
          issue_base
            .range(:closed_at, gte: begin_date, lte: end_date)
            .total_entries

        issue_unresponsive_count =
          issue_base
            .where(num_of_comments_without_bot: 0)
            .must(terms: { state: ['open', 'progressing'] })
            .total_entries

        issue_comments_count =
          issue_base
            .aggregate({ count: { sum: { field: "num_of_comments_without_bot" } }})
            .per(0)
            .execute
            .aggregations
            .dig('count', 'value')

        issue_state_distribution = distribute_by_field(issue_base, 'state', count)
        issue_comment_distribution = distribute_by_field(issue_base, 'num_of_comments_without_bot', count)

        {
          issue_count: count,
          issue_completion_count: closed_issue_count,
          issue_completion_ratio: count == 0 ? 0 : (closed_issue_count.to_f / count.to_f),
          issue_unresponsive_count: issue_unresponsive_count,
          issue_unresponsive_ratio: count == 0 ? 0 : (issue_unresponsive_count.to_f / count.to_f),
          issue_comment_frequency_mean: count == 0 ? 0 : (issue_comments_count.to_f / count.to_f),
          issue_state_distribution: issue_state_distribution,
          issue_comment_distribution: issue_comment_distribution
        }
      end
    end
  end
end
