# frozen_string_literal: true


module Openapi
  module V3
    module DeveloperJourney
      module DeveloperRetention
        class CoreLoss < Grape::API
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

          resource :core_loss do
            desc 'Org Code Core Loss / 组织代码核心开发者（含管理者）流失率',
                 detail: 'Ratio of last-period code core with no contribution in current period / 上个周期的代码核心在本周期没有任何贡献行为的比例',
                 tags: [
                   'Developer Journey / 开发者旅程评估',
                   'Developer Retention / 开发者留存',
                   'Core Loss / 核心开发者流失率'
                 ],
                 success: { code: 201, model: Openapi::Entities::CoreLossOrgCodeCoreLossResponse }
            params { use :metric_search }
            post :org_code_core_loss do
              fetch_metric_data_v2(CoreLossMetric, 'org_code_core_loss')
            end

            desc 'Org Issue Core Loss / 组织Issue核心开发者（含管理者）流失率',
                 detail: 'Ratio of last-period Issue core with no activity in current period / 上个周期的Issue核心在本周期无任何互动的比例',
                 tags: [
                   'Developer Journey / 开发者旅程评估',
                   'Developer Retention / 开发者留存',
                   'Core Loss / 核心开发者流失率'
                 ],
                 success: { code: 201, model: Openapi::Entities::CoreLossOrgIssueCoreLossResponse }
            params { use :metric_search }
            post :org_issue_core_loss do
              fetch_metric_data_v2(CoreLossMetric, 'org_issue_core_loss')
            end

            desc 'Individual Code Core Loss / 个人代码核心开发者（含管理者）流失率',
                 detail: 'Ratio of last-period individual code core with no contribution in current period / 上个周期的个人代码核心在本周期无任何贡献的比例',
                 tags: [
                   'Developer Journey / 开发者旅程评估',
                   'Developer Retention / 开发者留存',
                   'Core Loss / 核心开发者流失率'
                 ],
                 success: { code: 201, model: Openapi::Entities::CoreLossIndividualCodeCoreLossResponse }
            params { use :metric_search }
            post :individual_code_core_loss do
              fetch_metric_data_v2(CoreLossMetric, 'individual_code_core_loss')
            end

            desc 'Individual Issue Core Loss / 个人Issue核心开发者（含管理者）流失率',
                 detail: 'Ratio of last-period individual Issue core with no activity in current period / 上个周期的个人Issue核心在本周期无任何互动的比例',
                 tags: [
                   'Developer Journey / 开发者旅程评估',
                   'Developer Retention / 开发者留存',
                   'Core Loss / 核心开发者流失率'
                 ],
                 success: { code: 201, model: Openapi::Entities::CoreLossIndividualIssueCoreLossResponse }
            params { use :metric_search }
            post :individual_issue_core_loss do
              fetch_metric_data_v2(CoreLossMetric, 'individual_issue_core_loss')
            end
          end
        end
      end
    end
  end
end
