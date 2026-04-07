# frozen_string_literal: true


module Openapi
  module V3
    module DeveloperJourney
      module DeveloperRetention
        class CoreChurn < Grape::API
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

          resource :core_churn do
            desc 'Org Code Core Churn / 组织代码核心开发者（含管理者）淡出率',
                 detail: 'Ratio of last-period code core who downgraded to regular or visitor in current period / 上个周期的代码核心在本周期降级为常客或访客的比例',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Developer Journey / 开发者旅程评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::CoreChurnOrgCodeCoreChurnResponse }
            params { use :metric_search }
            post :org_code_core_churn do
              fetch_metric_data_v2(CoreChurnMetric, 'org_code_core_churn')
            end

            desc 'Org Issue Core Churn / 组织Issue核心开发者（含管理者）淡出率',
                 detail: 'Ratio of last-period Issue core who downgraded to regular or visitor in current period / 上个周期的Issue核心在本周期降级为常客或访客的比例',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Developer Journey / 开发者旅程评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::CoreChurnOrgIssueCoreChurnResponse }
            params { use :metric_search }
            post :org_issue_core_churn do
              fetch_metric_data_v2(CoreChurnMetric, 'org_issue_core_churn')
            end

            desc 'Individual Code Core Churn / 个人代码核心开发者（含管理者）淡出率',
                 detail: 'Ratio of last-period individual code core who downgraded to regular or visitor in current period / 上个周期的个人代码核心在本周期降级为常客或访客的比例',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Developer Journey / 开发者旅程评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::CoreChurnIndividualCodeCoreChurnResponse }
            params { use :metric_search }
            post :individual_code_core_churn do
              fetch_metric_data_v2(CoreChurnMetric, 'individual_code_core_churn')
            end

            desc 'Individual Issue Core Churn / 个人Issue核心开发者（含管理者）淡出率',
                 detail: 'Ratio of last-period individual Issue core who downgraded to regular or visitor in current period / 上个周期的个人Issue核心在本周期降级为常客或访客的比例',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Developer Journey / 开发者旅程评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::CoreChurnIndividualIssueCoreChurnResponse }
            params { use :metric_search }
            post :individual_issue_core_churn do
              fetch_metric_data_v2(CoreChurnMetric, 'individual_issue_core_churn')
            end

            desc 'Core Churn Model / 核心开发者流失模型',
                 detail: "
| Metrics / 度量指标 | Address / 地址 | Threshold / 阈值 | Weight / 权重 |
|---------|------|------|------|
| Org Code Core Churn / 组织代码核心开发者（含管理者）淡出率 | /api/v3/core_churn/org_code_core_churn | 1 | 0.25 |
| Org Issue Core Churn / 组织Issue核心开发者（含管理者）淡出率 | /api/v3/core_churn/org_issue_core_churn | 1 | 0.25 |
| Individual Code Core Churn / 个人代码核心开发者（含管理者）淡出率 | /api/v3/core_churn/individual_code_core_churn | 1 | 0.25 |
| Individual Issue Core Churn / 个人Issue核心开发者（含管理者）淡出率 | /api/v3/core_churn/individual_issue_core_churn | 1 | 0.25 |
",

                 tags: [
                   'V3 API',
                   'Evaluation Model / 评估模型',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Retention / 开发者留存'
                 ],
                 success: { code: 201, model: Openapi::Entities::CoreChurnModelDataResponse }
            params { use :metric_search }
            post :model_data do
              fields = %w[org_code_core_churn_rate org_issue_core_churn_rate individual_code_core_churn_rate individual_issue_core_churn_rate score]
              fetch_metric_data_v2(CoreChurnMetric, fields)
            end
          end
        end
      end
    end
  end
end
