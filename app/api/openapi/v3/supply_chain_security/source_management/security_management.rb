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
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Security Management / 安全管理'
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
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Security Management / 安全管理'
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
          end

        end
      end
    end
  end
end
