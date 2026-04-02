# frozen_string_literal: true


module Openapi
  module V3
    module SupplyChainSecurity
      module ReleaseAndMaintenance
        class MaintenanceManagement < Grape::API
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

          resource :maintenance_management do
            desc 'Lifecycle Statement / 生命周期申明',
                 detail: 'Check whether maintenance lifecycle/EOL policy is explicitly stated (EOL, Support Policy) / 检查是否明确声明了软件版本的维护周期及停止支持（EOL）策略。',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::LifecycleStatementResponse }
            params { use :metric_search }
            post :lifecycle_statement do
              fields = %w[
                lifecycle_statement
                lifecycle_statement_exists
                lifecycle_statement_detail
              ]
              fetch_metric_data_v2(MaintenanceManagementMetric, fields)
            end

            desc 'Average Vulnerability Fix Time / 安全漏洞平均修复时间',
                 detail: 'Average time from vulnerability report to fix merged / 统计从漏洞被报告到修复代码合入的平均耗时。',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::AvgVulnerabilityFixTimeResponse }
            params { use :metric_search }
            post :avg_vulnerability_fix_time do
              fields = %w[
                avg_vulnerability_fix_days
                avg_vulnerability_fix_unavailable
              ]
              fetch_metric_data_v2(MaintenanceManagementMetric, fields)
            end

            desc 'Maintenance Management Model Data / 维护管理模型数据',
                 detail: "
| 接口名称 | 地址 | 阈值 | 权重 |
|---------|------|------|------|
| Lifecycle Statement / 生命周期申明 | /api/v3/maintenance_management/lifecycle_statement | 1 | 0.50 |
| Average Vulnerability Fix Time / 安全漏洞平均修复时间 | /api/v3/maintenance_management/avg_vulnerability_fix_time | 30 | 0.50 |
",

                 tags: [
                   'V3 API',
                   'Evaluation Model / 评估模型',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Release and Maintenance / 发布与维护'
                 ],
                 success: { code: 201, model: Openapi::Entities::MaintenanceManagementModelDataResponse }
            params { use :metric_search }
            post :model_data do
              fields = %w[
                lifecycle_statement
                lifecycle_statement_exists
                lifecycle_statement_detail
                avg_vulnerability_fix_days
                avg_vulnerability_fix_unavailable
                score
              ]
              fetch_metric_data_v2(MaintenanceManagementMetric, fields)
            end
          end


        end
      end
    end
  end
end
