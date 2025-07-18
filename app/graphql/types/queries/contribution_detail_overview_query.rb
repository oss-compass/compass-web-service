# frozen_string_literal: true

module Types
  module Queries
    class ContributionDetailOverviewQuery < BaseOverviewQuery

      type Types::Meta::ContributionOverviewType, null: false
      description 'Overview of the value of contributions'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', begin_date: nil, end_date: nil)
        label = ShortenedLabel.normalize_label(label)

        login_required!(context[:current_user])
        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        indexers, repo_urls =
          select_idx_repos_by_lablel_and_level(
            label,
            level,
            [GiteeGitEnrich, GiteePullEnrich, GiteeIssueEnrich, GiteeContributorEnrich, GiteeStargazerEnrich, GiteeForkEnrich, GiteeWatchEnrich],
            [GithubGitEnrich, GithubPullEnrich, GithubIssueEnrich, GithubContributorEnrich, GithubStargazerEnrich, GithubForkEnrich, nil],
            [GitcodeGitEnrich, GitcodePullEnrich, GitcodeIssueEnrich, GitcodeContributorEnrich, GitcodeStargazerEnrich, GitcodeForkEnrich, nil]
          )
        base_type = Types::Meta::ContributionDetailOverviewType
        current_period_data = get_contribution_count(base_type, indexers, begin_date, end_date)
        previous_period_data = get_contribution_count(base_type, indexers, begin_date - (end_date - begin_date), begin_date)
        ratio = get_ratio(base_type, current_period_data, previous_period_data)

        {
          current_period: current_period_data,
          previous_period: previous_period_data,
          ratio: ratio,
        }
      end

      def get_contribution_count(base_type, indexers, begin_date, end_date)
        git_indexer, pull_indexer, issue_indexer, contributor_indexer, stargazer_indexer, fork_indexer, watch_indexer = indexers

        commit_aggs = { count_hash: { cardinality: { field: "hash" } } }
        commit_resp = git_indexer.aggs_repo_by_by_repo_urls(repo_urls, begin_date, end_date, aggs: commit_aggs)
        commit_count = commit_resp.dig('aggregations', 'count_hash', 'value') || 0

        pull_query = pull_indexer.where(pull_request: true)
                                  .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                                  .must(terms: { tag: repo_urls })
        pull_count = count_of(pull_query, 'uuid')

        issue_query = issue_indexer.where(pull_request: false)
                                    .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                                    .must(terms: { tag: repo_urls })
        issue_count = count_of(issue_query, 'uuid')

        contributor_and_org_query = contributor_indexer.range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                                                        .must(terms: { 'repo_name.keyword': repo_urls })
        contributor_count = count_of(contributor_and_org_query, 'contributor.keyword')
        org_count = count_of(contributor_and_org_query, 'organization.keyword')

        stargazer_query = stargazer_indexer.range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                                            .must(terms: { tag: repo_urls })
        star_count = count_of(stargazer_query, 'user_login')

        fork_query = fork_indexer.range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                                  .must(terms: { tag: repo_urls })
        fork_count = count_of(fork_query, 'user_login')

        if watch_indexer.present?
          watch_query = watch_indexer.range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                                      .must(terms: { tag: repo_urls })
          watch_count = count_of(watch_query, 'user_login')
        else
          watch_count = 0
        end
        result_data = {
          commit: commit_count,
          pull: pull_count,
          issue: issue_count,
          contributor: contributor_count,
          org: org_count,
          star: star_count,
          fork: fork_count,
          watch: watch_count,
        }
        skeleton = Hash[base_type.fields.keys.map(&:underscore).zip([])].symbolize_keys
        skeleton = skeleton.merge(result_data).symbolize_keys
        skeleton
      end

      def get_ratio(base_type, current_period_data, previous_period_data)
        ratio_hash = current_period_data.transform_values.with_index do |value, index|
          previous_period_count = previous_period_data[previous_period_data.keys[index]]
          previous_period_count > 0 ? ((value.to_f - previous_period_count) / previous_period_count).round(4) : 0
        end
        skeleton = Hash[base_type.fields.keys.map(&:underscore).zip([])].symbolize_keys
        skeleton = skeleton.merge(ratio_hash).symbolize_keys
        skeleton
      end

    end
  end
end
