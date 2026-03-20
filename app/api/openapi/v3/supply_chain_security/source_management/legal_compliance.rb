# frozen_string_literal: true

module Openapi
  module V3
    module SupplyChainSecurity
      module SourceManagement
        class LegalCompliance < Grape::API
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
          resource :legal_compliance do

            desc 'Legal Compliance: Copyright Statement Check / 许可头与版权声明',
                 detail: 'Software source files must include license headers and copyright statements / 软件源文件许可头与版权声明检查：项目的所有源码必须包含许可头与版权声明。',
                 tags: [
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Source Management / 源码管理',
                   'Legal Compliance / 合法合规'
                 ],
                 success: { code: 201, model: Openapi::Entities::ComplianceCopyrightStatementResponse }
            params { use :metric_search }
            post :compliance_copyright_statement do
              fields = %w[
                compliance_copyright_statement
                compliance_copyright_statement_detail
              ]
              fetch_metric_data_v2(LegalComplianceMetric, fields)
            end

            desc 'Legal Compliance: OSI License Check / 许可证包含（OSI）',
                 detail: 'Check OSI-approved license presence in the standard location / 软件许可证合规性检查：仓库标准位置包含许可证且许可证为OSI批准的开源许可证。',
                 tags: [
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Source Management / 源码管理',
                   'Legal Compliance / 合法合规'
                 ],
                 success: { code: 201, model: Openapi::Entities::ComplianceLicenseResponse }
            params { use :metric_search }
            post :compliance_license do
              fields = %w[
                license_included_osi
              ]
              fetch_metric_data_v2(LegalComplianceMetric, fields)
            end

            desc 'Legal Compliance: License Compatibility / 许可证兼容性',
                 detail: 'Check whether upstream licenses allow open-source contribution of derivative code / 软件许可证兼容性检查：针对衍生作品代码，检查上游软件的许可证是否允许贡献者将本衍生作品代码进行开源贡献。',
                 tags: [
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Source Management / 源码管理',
                   'Legal Compliance / 合法合规'
                 ],
                 success: { code: 201, model: Openapi::Entities::ComplianceLicenseCompatibilityResponse }
            params { use :metric_search }
            post :compliance_license_compatibility do
              fields = %w[
                compliance_license_compatibility
                compliance_license_compatibility_detail
                license_compatibility_conflicts
              ]
              fetch_metric_data_v2(LegalComplianceMetric, fields)
            end

            desc 'Legal Compliance: Anti-tamper for License & Copyright / 许可证与版权声明防篡改',
                 detail: 'Ensure upstream-derived license & copyright information is not tampered with / 软件涉及第三方开源软件的许可证和版权声明篡改检查：通过上游软件衍生的作品应当完整保留原上游软件的License及Copyright信息，项目中不能篡改第三方开源软件的许可证和版权声明。',
                 tags: [
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Source Management / 源码管理',
                   'Legal Compliance / 合法合规'
                 ],
                 success: { code: 201, model: Openapi::Entities::ComplianceCopyrightAntiTamperResponse }
            params { use :metric_search }
            post :compliance_copyright_anti_tamper do
              fields = %w[
                compliance_copyright_statement_anti_tamper
                compliance_copyright_statement_anti_tamper_detail

              ]
              fetch_metric_data_v2(LegalComplianceMetric, fields)
            end
          end

        end
      end
    end
  end
end
