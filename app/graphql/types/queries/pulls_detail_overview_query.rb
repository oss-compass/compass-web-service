# frozen_string_literal: true

module Types
  module Queries
    class PullsDetailOverviewQuery < BaseOverviewQuery

      attr_accessor :pull_indexer, :git_indexer, :repo_urls, :begin_date, :end_date

      type Types::Meta::PullDetailOverviewType, null: false
      description 'Get overview data of a pull detail'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', begin_date: nil, end_date: nil)
        label = ShortenedLabel.normalize_label(label)

        validate_by_label!(context[:current_user], label)

        @begin_date, @end_date, interval = extract_date(begin_date, end_date)
        @begin_date = @begin_date.to_date.to_s
        @end_date = @end_date.to_date.to_s

        indexers, @repo_urls =
                  select_idx_repos_by_lablel_and_level(
                    label,
                    level,
                    [GiteePullEnrich, GiteeGitEnrich],
                    [GithubPullEnrich, GithubGitEnrich]
                  )

        @pull_indexer, @git_indexer = indexers

        pull_base =
          pull_indexer
            .where(pull_request: true)
            .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
            .must(terms: { tag: repo_urls })

        git_base =
          git_indexer
            .must(range: { utc_commit: { gte: begin_date, lte: end_date } } )
            .must(terms: { tag: repo_urls.map { |url| "#{url}.git" } })

        count = count_of(pull_base, 'uuid')
        commit_count = count_of(git_base, 'uuid')

        closed_pull_count = count_of(
          pull_base
            .range(:closed_at, gte: begin_date, lte: end_date),
          'uuid'
        )

        pull_unresponsive_count = count_of(
          pull_base
            .where(num_review_comments_without_bot: 0)
            .must(terms: { state: ['open'] }),
          'uuid'
        )

        pull_state_distribution = distribute_by_field(pull_base, 'state', count)
        pull_comment_distribution = distribute_by_field(pull_base, 'num_review_comments_without_bot', count)

        {
          pull_count: count,
          pull_completion_count: closed_pull_count,
          pull_completion_ratio: count == 0 ? 0 : (closed_pull_count.to_f / count.to_f),
          pull_unresponsive_count: pull_unresponsive_count,
          pull_unresponsive_ratio: count == 0 ? 0 : (pull_unresponsive_count.to_f / count.to_f),
          commit_count: commit_count,
          pull_state_distribution: pull_state_distribution,
          pull_comment_distribution: pull_comment_distribution
        }
      end
    end
  end
end
