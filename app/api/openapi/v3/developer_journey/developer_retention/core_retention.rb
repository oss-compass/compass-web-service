# frozen_string_literal: true

CoreRetentionMetric = CustomV2Metric unless defined?(CoreRetentionMetric)

module Openapi
  module V3
    module DeveloperJourney
      module DeveloperRetention
        class CoreRetention < Grape::API
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

          resource :core_retention do
            desc 'Org Code Core Retention / 组织代码核心开发者（含管理者）留存率',
                 detail: 'Ratio of last-period code core contributors who remain core in current period / 上个周期的代码核心开发者在本周期依然保持为核心的比例',
                 tags: [
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Developer Journey / 开发者旅程',
                   'Core Retention / 核心开发者留存率'
                 ],
                 success: { code: 201, model: Openapi::Entities::CoreRetentionOrgCodeCoreRetentionResponse }
            params { use :metric_search }
            post :org_code_core_retention do
              fetch_metric_data_v2(CoreRetentionMetric, 'org_code_core_retention')
            end

            desc 'Org Issue Core Retention / 组织Issue核心开发者（含管理者）留存率',
                 detail: 'Ratio of last-period Issue core contributors who remain core in current period / 上个周期的Issue核心开发者在本周期依然保持为Issue核心的比例',
                 tags: [
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Developer Journey / 开发者旅程',
                   'Core Retention / 核心开发者留存率'
                 ],
                 success: { code: 201, model: Openapi::Entities::CoreRetentionOrgIssueCoreRetentionResponse }
            params { use :metric_search }
            post :org_issue_core_retention do
              fetch_metric_data_v2(CoreRetentionMetric, 'org_issue_core_retention')
            end

            desc 'Individual Code Core Retention / 个人代码核心开发者（含管理者）留存率',
                 detail: 'Ratio of last-period individual code core who remain core in current period / 上个周期的个人代码核心在本周期依然保持为核心的比例',
                 tags: [
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Developer Journey / 开发者旅程',
                   'Core Retention / 核心开发者留存率'
                 ],
                 success: { code: 201, model: Openapi::Entities::CoreRetentionIndividualCodeCoreRetentionResponse }
            params { use :metric_search }
            post :individual_code_core_retention do
              fetch_metric_data_v2(CoreRetentionMetric, 'individual_code_core_retention')
            end

            desc 'Individual Issue Core Retention / 个人Issue核心开发者（含管理者）留存率',
                 detail: 'Ratio of last-period individual Issue core who remain core in current period / 上个周期的个人Issue核心在本周期依然保持为Issue核心的比例',
                 tags: [
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Developer Journey / 开发者旅程',
                   'Core Retention / 核心开发者留存率'
                 ],
                 success: { code: 201, model: Openapi::Entities::CoreRetentionIndividualIssueCoreRetentionResponse }
            params { use :metric_search }
            post :individual_issue_core_retention do
              fetch_metric_data_v2(CoreRetentionMetric, 'individual_issue_core_retention')
            end
          end
        end
      end
    end
  end
end
