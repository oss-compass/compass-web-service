# frozen_string_literal: true

module Types
  module Queries
    class OverviewQuery < BaseQuery
      type Types::OverviewType, null: false
      description 'Get overview data of compass'

      def resolve
        skeleton = Hash[Types::OverviewType.fields.keys.zip([])].symbolize_keys
        skeleton['repos_count'] = aggs_distinct(GithubRepoEnrich, :origin) + aggs_distinct(GiteeRepoEnrich, :origin)
        skeleton['stargazers_count'] = aggs_sum(GithubRepoEnrich, :stargazers_count) + aggs_sum(GiteeRepoEnrich, :stargazers_count)
        skeleton['subscribers_count'] = aggs_sum(GithubRepoEnrich, :subscribers_count) + aggs_sum(GiteeRepoEnrich, :subscribers_count)
        skeleton['pulls_count'] = aggs_distinct(GithubPullEnrich, :id) + aggs_distinct(GiteePullEnrich, :id)
        skeleton['issues_count'] = aggs_distinct(GithubIssueEnrich, :id) + aggs_distinct(GiteeIssueEnrich, :id)
        resp =
          GithubRepo
            .exists(:origin)
            .sort('data.updated_at': 'desc').page(1).per(4)
            .source(['origin',
                     'backend_name',
                     'data.name',
                     'data.language',
                     'data.full_name',
                     'data.forks_count',
                     'data.subscribers_count',
                     'data.stargazers_count',
                     'data.open_issues_count',
                     'data.created_at',
                     'data.updated_at'])
              .execute
              .raw_response
        skeleton['trends'] = build_github_repo(resp).map { |repo| OpenStruct.new(repo) }
        OpenStruct.new(skeleton)
      end

      private

      def aggs_distinct(index, field, threshold=100)
        index.aggregate(
          {
            distinct: {
              cardinality: {
                field: field,
                precision_threshold: threshold
              }
            }
          }
        ).per(0).execute.raw_response['aggregations']['distinct']['value']
      rescue
        0
      end

      def aggs_sum(index, field)
        index.aggregate(
          {
            total: {
              sum: {
                field: field
              }
            }
          }
        ).per(0).execute.raw_response['aggregations']['total']['value']
      rescue
        0
      end
    end
  end
end
