# frozen_string_literal: true

module Openapi
  module V3
    module SupplyChainSecurity
      module SourceManagement
        class SecurityManagement < Grape::API
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

          resource :security_management do
            desc 'Vulnerability Disclosure / 漏洞响应与披露',
                 detail: 'Open source software must provide a vulnerability reporting and fix-tracking mechanism / 开源软件必须有漏洞反馈与修复跟踪管理机制。',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::VulnerabilityDisclosureResponse }
            params { use :metric_search }
            post :vulnerability_disclosure do
              fields = %w[
                vulnerability_disclosure_has_channel
                security_md_exists
                avg_vuln_close_days
                vulnerability_disclosure_detail
              ]
              fetch_metric_data_v2(SecurityManagementMetric, fields)
            end

            desc 'Unfixed Public Vulnerabilities / 公开未修复漏洞',
                 detail: 'Check publicly disclosed but unfixed vulnerabilities (prefer OpenCheck/OSV results) / 软件及依赖源码是否有公开未修复漏洞检查。',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::SecurityVulnerabilityResponse }
            params { use :metric_search }
            post :security_vulnerability do
              fields = %w[
                security_vulnerability
                security_vulnerability_detail
                vuln_counts
                security_vulnerability_raw
              ]
              fetch_metric_data_v2(SecurityManagementMetric, fields)
            end

            desc 'Security Management Model / 安全管理模型',
                 detail: "
| Metrics / 度量指标 | Address / 地址 | Threshold / 阈值 | Weight / 权重 |
|---------|------|------|------|
| Vulnerability Disclosure / 漏洞响应与披露 | /api/v3/security_management/vulnerability_disclosure | 1 | 0.50 |
| Unfixed Public Vulnerabilities / 公开未修复漏洞 | /api/v3/security_management/security_vulnerability | 1 | 0.50 |
",

                 tags: [
                   'V3 API',
                   'Evaluation Model / 评估模型',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Source Management / 源码管理'
                 ],
                 success: { code: 201, model: Openapi::Entities::SecurityManagementModelDataResponse }
            params { use :metric_search }
            post :model_data do
              fields = %w[
                vulnerability_disclosure_has_channel
                security_md_exists
                avg_vuln_close_days
                vulnerability_disclosure_detail
                security_vulnerability
                security_vulnerability_detail
                vuln_counts
                security_vulnerability_raw
                score
              ]
              fetch_metric_data_v2(SecurityManagementMetric, fields)
            end
          end

        end
      end
    end
  end
end
