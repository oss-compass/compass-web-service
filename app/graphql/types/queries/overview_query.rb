# frozen_string_literal: true

module Types
  module Queries
    class OverviewQuery < BaseQuery
      DIMENSIONS_COUNT = ENV.fetch('DIMENSIONS') { 3 }
      MODELS_COUNT = ENV.fetch('MODELS') { 24 }
      METRICS_COUNT = ENV.fetch('METRICS') { 72 }

      type Types::OverviewType, null: false
      description 'Get overview data of compass'

      def resolve
        skeleton = Hash[Types::OverviewType.fields.keys.zip([])].symbolize_keys
        skeleton['projects_count'] = aggs_distinct(GithubRepoEnrich, :origin) + aggs_distinct(GiteeRepoEnrich, :origin)
        skeleton['dimensions_count'] = DIMENSIONS_COUNT
        skeleton['models_count'] = MODELS_COUNT
        skeleton['metrics_count'] = METRICS_COUNT
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
