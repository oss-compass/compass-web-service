# frozen_string_literal: true

module Types
  module Queries
    class CommunityDetailOverviewQuery < BaseQuery

      type Types::Meta::CommunityDetailOverviewType, null: false
      description 'Get overview data of a contributor detail'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', begin_date: nil, end_date: nil)
        label = ShortenedLabel.normalize_label(label)

        login_required!(context[:current_user])
        validate_by_label!(context[:current_user], label)

        repo_type = level == 'repo' ? nil : (repo_type || 'software-artifact')

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        commit_indexer, repo_urls, origin = select_idx_repos_by_lablel_and_level(label, level, GiteeGitEnrich, GithubGitEnrich)
        subject = Subject.find_by(label: label, level: level)
        subject_sig = subject.community_sigs

        commit_aggs = { count_hash: { cardinality: { field: "hash" } } }
        commit_resp = commit_indexer.aggs_repo_by_by_repo_urls(repo_urls, begin_date, end_date, aggs: commit_aggs)

        activity_aggs = { avg_score: { avg: { field: ActivityMetric.main_score } } }
        activity_resp= ActivityMetric.aggs_repo_by_date(label, begin_date, end_date, activity_aggs, type: repo_type)

        community_aggs = { avg_score: { avg: { field: CommunityMetric.main_score } } }
        community_resp= CommunityMetric.aggs_repo_by_date(label, begin_date, end_date, community_aggs, type: repo_type)


        {
          repo_count: repo_urls.length,
          sig_count: subject_sig.length,
          activity_score_avg: [activity_resp.dig('aggregations', 'avg_score', 'value'), 0].compact.max.round(4),
          community_score_avg: [community_resp.dig('aggregations', 'avg_score', 'value'), 0].compact.max.round(4),
          commit_count: commit_resp.dig('aggregations', 'count_hash', 'value') || 0
        }
      end
    end
  end
end
