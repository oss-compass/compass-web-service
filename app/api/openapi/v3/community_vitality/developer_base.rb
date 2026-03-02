# frozen_string_literal: true

module Openapi
  module V3
    module CommunityVitality
      class DeveloperBase < Grape::API
        version 'v3', using: :path
        prefix :api
        format :json

        helpers Openapi::SharedParams::CustomMetricSearch
        helpers Openapi::SharedParams::AuthHelpers
        helpers Openapi::SharedParams::ErrorHelpers
        helpers Openapi::SharedParams::RestapiHelpers

        rescue_from :all do |e|
          case e
          when Grape::Exceptions::ValidationErrors
            handle_validation_error(e)
          when SearchFlip::ResponseError
            handle_open_search_error(e)
          else
            handle_generic_error(e)
          end
        end

        before { require_token! }
        before do
          token = params[:access_token]
          Openapi::SharedParams::RateLimiter.check_token!(token)
        end

        resource :developer_base do
          desc 'Community Contributor Count / 社区贡献者数量',
               detail: 'Number of unique users with any contribution behavior during the period / 周期内有任何贡献行为的去重用户数 ',
               tags: [
                 'Community Ecosystem Health / 社区生态健康评估',
                 'Community Vitality / 社区活力',
                 'Developer Base / 开发者基数'
               ],

               success: { code: 201, model: Openapi::Entities::CommunityContributorCountResponse }
          params { use :metric_search }
          post :contributor_count do
            fetch_metric_data_v2(DeveloperBaseMetric, 'total_active_contributors')
          end

          desc 'Active Code Contributor Count / 代码贡献者数量',
               detail: 'Number of unique users with code commits, PR merges, or PR comments during the period / 周期内有代码提交或PR合并或PR评论的去重用户数',
               tags: [
                 'Community Ecosystem Health / 社区生态健康评估',
                 'Community Vitality / 社区活力',
                 'Developer Base / 开发者基数'
               ],
               success: { code: 201, model: Openapi::Entities::ActiveCodeContributorCountResponse }
          params { use :metric_search }
          post :code_contributor_count do
            fetch_metric_data_v2(DeveloperBaseMetric, 'code_contributors')
          end

          desc 'Active Non-code Contributor Count / 非代码贡献者数量',
               detail: 'Number of users who only participated in discussions but did not submit code during the period / 周期内仅参与讨论但未提交代码的用户数',
               tags: [
                 'Community Ecosystem Health / 社区生态健康评估',
                 'Community Vitality / 社区活力',
                 'Developer Base / 开发者基数'
               ],
               success: { code: 201, model: Openapi::Entities::NonCodeContributorCountResponse }
          params { use :metric_search }
          post :non_code_contributor_count do
            fetch_metric_data_v2(DeveloperBaseMetric, 'non_code_contributors')
          end
        end
      end
    end
  end
end
