# frozen_string_literal: true

module Types
  module Queries
    class OverviewQuery < BaseQuery
      DIMENSIONS_COUNT = ENV.fetch('DIMENSIONS') { 3 }
      MODELS_COUNT = ENV.fetch('MODELS') { 24 }
      METRICS_COUNT = ENV.fetch('METRICS') { 72 }
      OVERVIEW_CACHE_KEY = 'compass-overview'

      type Types::OverviewType, null: false
      description 'Get overview data of compass'

      GiteeFixedTemplates = []
      GithubFixedTemplates = []

      def resolve
        results =
          Rails.cache.fetch(OVERVIEW_CACHE_KEY, expires_in: 2.hours) do
          skeleton = Hash[Types::OverviewType.fields.keys.zip([])].symbolize_keys
          skeleton['projects_count'] =
            aggs_distinct(GithubRepoEnrich, :origin) + aggs_distinct(GiteeRepoEnrich, :origin)
          skeleton['dimensions_count'] = DIMENSIONS_COUNT
          skeleton['models_count'] = MODELS_COUNT
          skeleton['metrics_count'] = METRICS_COUNT

          fetch_top50_by_phrase = -> (domain) {
            ActivityMetric
              .must(match_phrase: { 'label': domain })
              .custom(collapse: { field: 'label.keyword' })
              .range(:grimoire_creation_date, gte: Date.today.end_of_day - 1.month, lte: Date.today.end_of_day)
              .page(1)
              .per(50)
              .sort(activity_score: :desc)
              .source(['label'])
              .execute
              .raw_response['hits']['hits'].map{ |row| row['_source']['label'] }
          }

          gitee_activity_top50_last_month = fetch_top50_by_phrase.('gitee.com')
          github_activity_top50_last_month = fetch_top50_by_phrase.('github.com')

          activity_upward_trending =
            ActivityMetric
              .range(:grimoire_creation_date, gte: Date.today.end_of_day - 1.month, lte: Date.today.end_of_day)
              .sort(grimoire_creation_date: :desc)
              .per(0)
              .aggregate(
                {
                  label_group: {
                    terms: {
                      field: "label.keyword",
                      size: 100
                    },
                    aggs: {
                      arise: {
                        date_histogram: {
                          field: :grimoire_creation_date,
                          interval: "week",
                        },
                        aggs: {
                          avg_activity: {
                            avg: {
                              field: "activity_score"
                            }
                          },
                          the_delta: {
                            derivative: {
                              buckets_path: "avg_activity"
                            }
                          }
                        }
                      }
                    }
                  }
                })
              .execute
              .aggregations&.[]('label_group')&.[]('buckets')
              .select { |row| row['arise']['buckets'].last&.[]('the_delta')&.[]('value').to_f > 0.001 }
              .map { |row| row['key'] }

          candidate_set =
            (activity_upward_trending || []) +
            (gitee_activity_top50_last_month || []) +
            (github_activity_top50_last_month || [])

          candidate_set =
            { community_support_score: CommunityMetric, code_quality_guarantee: CodequalityMetric }.map do |score, metric|
            metric
              .where({'label.keyword' => candidate_set})
              .range(:grimoire_creation_date, gte: Date.today.end_of_day - 1.month, lte: Date.today.end_of_day)
              .per(0)
              .aggregate(
                {
                  label_group: {
                    terms: {
                      field: "label.keyword",
                      size: candidate_set.length
                    },
                    aggs: {
                      avg_score: {
                        avg: {
                          field: score
                        }
                      }
                    }
                  }
                })
              .execute
              .aggregations&.[]('label_group')&.[]('buckets')
              .select { |row| row['avg_score']&.[]('value').to_f > 0.0 }
              .map { |row| row['key'] }
          end.reduce(&:&)

          gitee_repos = candidate_set.select {|row| row =~ /gitee\.com/ }.sample(18)
          github_repos = candidate_set.select {|row| row =~ /github\.com/ }.sample(18)
          resp = GithubRepo.only(github_repos)
          resp2 = GiteeRepo.only(gitee_repos)
          skeleton['trends'] = build_github_repo(resp).map { |repo| OpenStruct.new(repo) }
          skeleton['trends'] += build_gitee_repo(resp2).map { |repo| OpenStruct.new(repo) }
          skeleton['trends'] = skeleton['trends'].shuffle()
          skeleton
        end
        OpenStruct.new(results)
      end
    end
  end
end
