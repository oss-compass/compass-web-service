# frozen_string_literal: true

module Openapi
  module V3
    module DeveloperJourney
      module DeveloperGrowth
        class DeveloperPromotion < Grape::API
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
          before { save_tracking_api! }

          resource :developer_promotion do
            desc 'Org Code Core Promotion Count / 组织代码核心晋升数量',
                 detail: 'Count of org members promoted to code core tier in the period / 本周期内晋升为代码核心层级的组织成员数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Developer Promotion / 开发者晋升'
                 ],
                 success: { code: 201, model: Openapi::Entities::DeveloperPromotionOrgCodeCorePromotionCountResponse }
            params { use :metric_search }
            post :org_code_core_promotion_count do
              fetch_metric_data_v2(DeveloperPromotionMetric, 'org_code_core_promotion_count')
            end

            desc 'Org Issue Core Promotion Count / 组织Issue核心晋升数量',
                 detail: 'Count of org members promoted to Issue core tier in the period / 本周期内晋升为Issue核心层级的组织成员数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Developer Promotion / 开发者晋升'
                 ],
                 success: { code: 201, model: Openapi::Entities::DeveloperPromotionOrgIssueCorePromotionCountResponse }
            params { use :metric_search }
            post :org_issue_core_promotion_count do
              fetch_metric_data_v2(DeveloperPromotionMetric, 'org_issue_core_promotion_count')
            end

            desc 'Individual Code Core Promotion Count / 个人代码核心晋升数量',
                 detail: 'Count of individual developers promoted to code core tier in the period / 本周期内晋升为代码核心层级的个人开发者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Developer Promotion / 开发者晋升'
                 ],
                 success: { code: 201, model: Openapi::Entities::DeveloperPromotionIndividualCodeCorePromotionCountResponse }
            params { use :metric_search }
            post :individual_code_core_promotion_count do
              fetch_metric_data_v2(DeveloperPromotionMetric, 'individual_code_core_promotion_count')
            end

            desc 'Individual Issue Core Promotion Count / 个人Issue核心晋升数量',
                 detail: 'Count of individual developers promoted to Issue core tier in the period / 本周期内晋升为Issue核心层级的个人开发者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Developer Promotion / 开发者晋升'
                 ],
                 success: { code: 201, model: Openapi::Entities::DeveloperPromotionIndividualIssueCorePromotionCountResponse }
            params { use :metric_search }
            post :individual_issue_core_promotion_count do
              fetch_metric_data_v2(DeveloperPromotionMetric, 'individual_issue_core_promotion_count')
            end

            desc 'Developer Promotion Model Data / 开发者晋升模型数据',
                 detail: 'Developer Promotion Model Data / 开发者晋升模型数据',
                 tags: [
                   'V3 API',
                   'Metrics Model Data / 模型数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Developer Promotion / 开发者晋升'
                 ],
                 success: { code: 201, model: Openapi::Entities::DeveloperPromotionModelDataResponse }
            params { use :metric_search }
            post :model_data do
              fields = %w[org_code_core_promotion_count org_issue_core_promotion_count individual_code_core_promotion_count individual_issue_core_promotion_count score]
              fetch_metric_data_v2(DeveloperPromotionMetric, fields)
            end
          end
        end
      end
    end
  end
end
