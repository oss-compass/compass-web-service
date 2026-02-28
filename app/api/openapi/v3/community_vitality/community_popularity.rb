# frozen_string_literal: true

module Openapi
  module V3
    module CommunityVitality
      class CommunityPopularity < Grape::API
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

        # before { require_token! }
        # before do
        #   token = params[:access_token]
        #   Openapi::SharedParams::RateLimiter.check_token!(token)
        # end

        resource :community_popularity do
          desc '项目关注度 / Stars Growth',
               detail: '定义：周期内新增的Star关注数。输入：本周期Star总数 - 上周期Star总数。输出：新增个数（个），本周期Star总数。参考：https://insights.linuxfoundation.org/docs/metrics/popularity/',
               tags: ['Metrics Data / 指标数据', 'Community Vitality / 社区活力', 'Community Popularity / 社区流行度'],
               success: { code: 201, model: Openapi::Entities::IssueUnresponsiveRateResponse }
          params { use :metric_search }
          post :stars do
            fields = %w[stars_added stars_total]
            fetch_metric_data_v2(CommunityPopularityMetric, fields)
          end

          desc 'Forks / Forks Growth',
               detail: '定义：周期内新增的Forks数。输入：本周期Forks总数 - 上周期Forks总数。输出：新增个数（个），本周期Forks总数。',
               tags: ['Metrics Data / 指标数据', 'Community Vitality / 社区活力', 'Community Popularity / 社区流行度'],
               success: { code: 201, model: Openapi::Entities::IssueUnresponsiveRateResponse }
          params { use :metric_search }
          post :forks do
            fields = %w[forks_added forks_total]
            fetch_metric_data_v2(CommunityPopularityMetric, fields)
          end
        end
      end
    end
  end
end
