# frozen_string_literal: true

module Openapi
  module V3
    module CommunityHealth
      module DevelopmentGovernance
        class OrganizationalGovernance < Grape::API
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

          resource :organizational_governance do

            desc 'Participating Orgs by Period / 参与贡献的组织个数',
                 detail: 'Number of organizations contributing during the period / 周期内参与贡献的组织个数',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Organizational Governance / 组织开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::ParticipatingOrgsResponse }
            params { use :metric_search }
            post :participating_orgs_by_period do
              fetch_metric_data_v2(OrganizationalGovernanceMetric, 'participating_orgs')
            end

            desc 'Org Code Contributors by Period / 组织代码贡献者数量',
                 detail: 'Number of org contributors with code contributions during the period / 周期内参与代码贡献的组织贡献者个数',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Organizational Governance / 组织开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::OrgCodeContributorsResponse }
            params { use :metric_search }
            post :org_code_contributors_by_period do
              fetch_metric_data_v2(OrganizationalGovernanceMetric, 'org_code_contributors')
            end

            desc 'Org Code Contributors Ratio by Period / 组织代码贡献者占比',
                 detail: 'Ratio of org code contributors to total code contributors in the period / 周期内组织代码贡献者数量占总代码贡献者数量比例',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Organizational Governance / 组织开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::OrgCodeContributorsRatioResponse }
            params { use :metric_search }
            post :org_code_contributors_ratio_by_period do
              fields = %w[org_code_contributors_ratio total_code_contributors]
              fetch_metric_data_v2(OrganizationalGovernanceMetric, fields)
            end

            desc 'Org Code Contribution by Period / 组织代码贡献量',
                 detail: 'Lines of code contributed by organizations during the period / 周期内组织贡献的代码量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Organizational Governance / 组织开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::OrgCodeContributionResponse }
            params { use :metric_search }
            post :org_code_contribution_by_period do
              fetch_metric_data_v2(OrganizationalGovernanceMetric, 'org_code_contribution')
            end

            desc 'Org Code Contribution Ratio by Period / 组织代码贡献量占比',
                 detail: 'Ratio of org code contribution to total code contribution in the period / 周期内组织贡献的代码占总代码量的比值',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Organizational Governance / 组织开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::OrgCodeContributionRatioResponse }
            params { use :metric_search }
            post :org_code_contribution_ratio_by_period do
              fields = %w[org_code_contribution_ratio total_code_contribution]
              fetch_metric_data_v2(OrganizationalGovernanceMetric, fields)
            end

            desc 'Org Non-code Contributors by Period / 组织非代码贡献者数量',
                 detail: 'Number of org contributors with non-code contributions during the period / 周期内参与非代码贡献的组织贡献者个数',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Organizational Governance / 组织开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::OrgNonCodeContributorsResponse }
            params { use :metric_search }
            post :org_non_code_contributors_by_period do
              fetch_metric_data_v2(OrganizationalGovernanceMetric, 'org_non_code_contributors')
            end

            desc 'Org Non-code Contributors Ratio by Period / 组织非代码贡献者占比',
                 detail: 'Ratio of org non-code contributors to total non-code contributors in the period / 周期内组织非代码贡献者占总非代码贡献者数量比例',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Organizational Governance / 组织开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::OrgNonCodeContributorsRatioResponse }
            params { use :metric_search }
            post :org_non_code_contributors_ratio_by_period do
              fields = %w[org_non_code_contributors_ratio total_non_code_contributors]
              fetch_metric_data_v2(OrganizationalGovernanceMetric, fields)
            end

            desc 'Org Non-code Contribution by Period / 组织非代码贡献量',
                 detail: 'Non-code contribution count by organizations during the period / 周期内组织非代码贡献量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Organizational Governance / 组织开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::OrgNonCodeContributionResponse }
            params { use :metric_search }
            post :org_non_code_contribution_by_period do
              fetch_metric_data_v2(OrganizationalGovernanceMetric, 'org_non_code_contribution')
            end

            desc 'Org Non-code Contribution Ratio by Period / 组织非代码贡献量占比',
                 detail: 'Ratio of org non-code contribution to total non-code contribution in the period / 周期内组织非代码贡献量占总非代码贡献量比例',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Organizational Governance / 组织开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::OrgNonCodeContributionRatioResponse }
            params { use :metric_search }
            post :org_non_code_contribution_ratio_by_period do
              fields = %w[org_non_code_contribution_ratio total_non_code_contribution]
              fetch_metric_data_v2(OrganizationalGovernanceMetric, fields)
            end

            desc 'Governance Orgs by Period / 参与治理的组织个数',
                 detail: 'Number of distinct organizations in governance roles (excluding community-initiated orgs) during the period / 周期内参与治理的去重组织数量（不含社区发起组织）',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Organizational Governance / 组织开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::GovernanceOrgsResponse }
            params { use :metric_search }
            post :governance_orgs_by_period do
              fetch_metric_data_v2(OrganizationalGovernanceMetric, 'governance_orgs')
            end

            desc 'Org Managers by Period / 组织管理者数量',
                 detail: 'Number of distinct managers from organizations (excluding community-initiated orgs) in governance roles during the period / 周期内来自非社区发起组织的去重管理者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Organizational Governance / 组织开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::OrgManagersResponse }
            params { use :metric_search }
            post :org_managers_by_period do
              fetch_metric_data_v2(OrganizationalGovernanceMetric, 'org_managers')
            end

            desc 'Org Managers Ratio by Period / 组织管理者数量占比',
                 detail: 'Ratio of org managers to total managers in the period / 周期内组织管理者数量占总管理者数量的比例',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Organizational Governance / 组织开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::OrgManagersRatioResponse }
            params { use :metric_search }
            post :org_managers_ratio_by_period do
              fields = %w[org_managers_ratio total_managers]
              fetch_metric_data_v2(OrganizationalGovernanceMetric, fields)
            end

            desc 'Organizational Governance Model Data / 组织开放治理模型数据',
                 detail: 'Organizational Governance Model Data / 组织开放治理模型数据',
                 tags: [
                   'V3 API',
                   'Metrics Model Data / 模型数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Organizational Governance / 组织开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::OrganizationalGovernanceModelDataResponse }
            params { use :metric_search }
            post :model_data do
              fields = %w[participating_orgs org_code_contributors org_code_contributors_ratio total_code_contributors org_code_contribution org_code_contribution_ratio total_code_contribution org_non_code_contributors org_non_code_contributors_ratio total_non_code_contributors org_non_code_contribution org_non_code_contribution_ratio total_non_code_contribution governance_orgs org_managers org_managers_ratio total_managers score]
              fetch_metric_data_v2(OrganizationalGovernanceMetric, fields)
            end
          end
        end
      end
    end
  end
end
