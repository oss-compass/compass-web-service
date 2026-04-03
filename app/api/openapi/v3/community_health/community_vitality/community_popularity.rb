# frozen_string_literal: true

module Openapi
  module V3
    module CommunityHealth
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

          before { require_token! }
          before do
            token = params[:access_token]
            Openapi::SharedParams::RateLimiter.check_token!(token)
          end

          resource :community_popularity do
            desc 'Stars Growth / 项目Stars新增',
                 detail: 'The number of new Stars followed during the period / 周期内新增的Star关注数',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Community Ecosystem Health / 社区生态健康评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::StarsResponse }
            params { use :metric_search }
            post :stars do
              fields = %w[stars_added stars_total]
              fetch_metric_data_v2(CommunityPopularityMetric, fields)
            end

            desc 'Forks Growth / 项目Forks新增',
                 detail: 'The number of new Forks during the period / 周期内新增的Forks数',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Community Ecosystem Health / 社区生态健康评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::ForksResponse }
            params { use :metric_search }
            post :forks do
              fields = %w[forks_added forks_total]
              fetch_metric_data_v2(CommunityPopularityMetric, fields)
            end

            desc 'Community Popularity Model Data / 社区流行度模型数据',
                 detail: "
| Metrics / 度量指标 | Address / 地址 | Threshold / 阈值 | Weight / 权重 |
|---------|------|------|------|
| Stars Growth / 项目Stars新增 | /api/v3/community_popularity/stars | 100 | 0.50 |
| Forks Growth / 项目Forks新增 | /api/v3/community_popularity/forks | 100 | 0.50 |
",

                 tags: [
                   'V3 API',
                   'Evaluation Model / 评估模型',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Community Vitality / 社区活力'
                 ],
                 success: { code: 201, model: Openapi::Entities::CommunityPopularityModelDataResponse }
            params { use :metric_search }
            post :model_data do
              fields = %w[stars_added stars_total forks_added forks_total score]
              fetch_metric_data_v2(CommunityPopularityMetric, fields)
            end
          end
        end
      end
    end
  end
end
