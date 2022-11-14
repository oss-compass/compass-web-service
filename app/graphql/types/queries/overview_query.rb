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

      GiteeFixedTemplates = [
        'https://gitee.com/jfinal/jfinal',
        'https://gitee.com/ld/J2Cache',
        'https://gitee.com/mindspore/mindspore',
        'https://gitee.com/smartide/SmartIDE',
        'https://gitee.com/GreatSQL/GreatSQL',
        'https://gitee.com/openeuler/kernel',
        'https://gitee.com/openarkcompiler/OpenArkCompiler',
        'https://gitee.com/Tencent/TencentOS-tiny',
        'https://gitee.com/openeuler/A-Tune',
        'https://gitee.com/openeuler/stratovirt',
        'https://gitee.com/erzhongxmu/jeewms',
        'https://gitee.com/mindspore/mindscience',
        'https://gitee.com/vant-contrib/vant',
        'https://gitee.com/LinkWeChat/link-wechat',
        'https://gitee.com/sjqzhang/go-fastdfs',
        'https://gitee.com/wfchat/im-server'
      ]
      GithubFixedTemplates = [
        'https://github.com/livebook-dev/livebook',
        'https://github.com/ruby/ruby',
        'https://github.com/phoenixframework/phoenix',
        'https://github.com/rails/rails',
        'https://github.com/elixir-lang/elixir',
        'https://github.com/phoenixframework/phoenix_live_view',
        'https://github.com/gin-gonic/gin',
        'https://github.com/grpc/grpc-go'
      ]

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
              .range(:grimoire_creation_date, gte: DateTime.now() - 1.month, lte: DateTime.now())
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
              .range(:grimoire_creation_date, gte: DateTime.now() - 1.month, lte: DateTime.now())
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
              .range(:grimoire_creation_date, gte: DateTime.now() - 1.month, lte: DateTime.now())
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

          gitee_repos = candidate_set.select {|row| row =~ /gitee\.com/ }.sample(12)
          github_repos = candidate_set.select {|row| row =~ /github\.com/ }.sample(12)
          resp = GithubRepo.only(github_repos)
          resp2 = GiteeRepo.only(gitee_repos)
          skeleton['trends'] = build_github_repo(resp).map { |repo| OpenStruct.new(repo) }
          skeleton['trends'] += build_gitee_repo(resp2).map { |repo| OpenStruct.new(repo) }
          skeleton['trends'] = skeleton['trends'].shuffle()
          skeleton
        end
        OpenStruct.new(results)
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
