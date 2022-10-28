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
          Rails.cache.fetch(OVERVIEW_CACHE_KEY, expires_in: 1.day) do
          skeleton = Hash[Types::OverviewType.fields.keys.zip([])].symbolize_keys
          skeleton['projects_count'] =
            aggs_distinct(GithubRepoEnrich, :origin) + aggs_distinct(GiteeRepoEnrich, :origin)
          skeleton['dimensions_count'] = DIMENSIONS_COUNT
          skeleton['models_count'] = MODELS_COUNT
          skeleton['metrics_count'] = METRICS_COUNT
          resp = GithubRepo.only(GithubFixedTemplates)
          resp2 = GiteeRepo.only(GiteeFixedTemplates)
          skeleton['trends'] = build_github_repo(resp).map { |repo| OpenStruct.new(repo) }
          skeleton['trends'] += build_gitee_repo(resp2).map { |repo| OpenStruct.new(repo) }
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
