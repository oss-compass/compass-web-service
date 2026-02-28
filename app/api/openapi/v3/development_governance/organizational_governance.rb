# frozen_string_literal: true

module Openapi
  module V3
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

          desc '参与贡献的组织个数 / Participating Orgs by Period',
               detail: '定义：周期内参与贡献的组织个数。输入：周期内贡献者列表（包含所属组织信息）。输出：组织数（个）。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Organizational Governance / 组织开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :participating_orgs_by_period do
            fetch_metric_data_v2(OrganizationalGovernanceMetric, 'participating_orgs')
          end

          desc '组织代码贡献者数量 / Org Code Contributors by Period',
               detail: '定义：周期内参与代码贡献的组织贡献者个数。输入：周期内贡献者列表（包含所属组织信息）。输出：人数（个）。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Organizational Governance / 组织开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :org_code_contributors_by_period do
            fetch_metric_data_v2(OrganizationalGovernanceMetric, 'org_code_contributors')
          end

          desc '组织代码贡献者占比 / Org Code Contributors Ratio by Period',
               detail: '定义：周期内参与代码贡献的组织贡献者数量占总代码贡献者数量比例。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Organizational Governance / 组织开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :org_code_contributors_ratio_by_period do
            fields = %w[org_code_contributors_ratio total_code_contributors]
            fetch_metric_data_v2(OrganizationalGovernanceMetric, fields)
          end

          desc '组织代码贡献量 / Org Code Contribution by Period',
               detail: '定义：周期内组织贡献的代码量。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Organizational Governance / 组织开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :org_code_contribution_by_period do
            fetch_metric_data_v2(OrganizationalGovernanceMetric, 'org_code_contribution')
          end

          desc '组织代码贡献量占比 / Org Code Contribution Ratio by Period',
               detail: '定义：周期内组织贡献的代码占总代码量的比值。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Organizational Governance / 组织开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :org_code_contribution_ratio_by_period do
            fields = %w[org_code_contribution_ratio total_code_contribution]
            fetch_metric_data_v2(OrganizationalGovernanceMetric, fields)
          end

          desc '组织非代码贡献者数量 / Org Non-code Contributors by Period',
               detail: '定义：周期内参与非代码贡献的组织贡献者个数。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Organizational Governance / 组织开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :org_non_code_contributors_by_period do
            fetch_metric_data_v2(OrganizationalGovernanceMetric, 'org_non_code_contributors')
          end

          desc '组织非代码贡献者占比 / Org Non-code Contributors Ratio by Period',
               detail: '定义：周期内组织非代码贡献者占总非代码贡献者数量比例。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Organizational Governance / 组织开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :org_non_code_contributors_ratio_by_period do
            fields = %w[org_non_code_contributors_ratio total_non_code_contributors]
            fetch_metric_data_v2(OrganizationalGovernanceMetric, fields)
          end

          desc '组织非代码贡献量 / Org Non-code Contribution by Period',
               detail: '定义：周期内组织非代码贡献量。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Organizational Governance / 组织开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :org_non_code_contribution_by_period do
            fetch_metric_data_v2(OrganizationalGovernanceMetric, 'org_non_code_contribution')
          end

          desc '组织非代码贡献量占比 / Org Non-code Contribution Ratio by Period',
               detail: '定义：周期内组织非代码贡献量占总非代码贡献量比例。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Organizational Governance / 组织开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :org_non_code_contribution_ratio_by_period do
            fields = %w[org_non_code_contribution_ratio total_non_code_contribution]
            fetch_metric_data_v2(OrganizationalGovernanceMetric, fields)
          end

          desc '参与治理的组织个数 / Governance Orgs by Period',
               detail: '定义：周期内在社区治理角色中，来自非社区发起组织的去重组织数量。输入：社区治理角色成员列表，成员所属机构信息，社区发起组织的名单。输出：组织数（个）。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Organizational Governance / 组织开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :governance_orgs_by_period do
            fetch_metric_data_v2(OrganizationalGovernanceMetric, 'governance_orgs')
          end

          desc '组织管理者数量 / Org Managers by Period',
               detail: '定义：周期内在社区治理角色中，来自非社区发起组织的去重管理者数量。输入：社区治理角色成员列表，成员所属机构信息，社区发起组织的名单。输出：人数（个）。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Organizational Governance / 组织开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :org_managers_by_period do
            fetch_metric_data_v2(OrganizationalGovernanceMetric, 'org_managers')
          end

          desc '组织管理者数量占比 / Org Managers Ratio by Period',
               detail: '定义：周期内在社区治理角色中，来自组织（非个人）的管理者数量占总管理者数量的比例。输入：组织管理者数量（分子），周期内总管理者数量（分母）。输出：百分比（%）。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Organizational Governance / 组织开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :org_managers_ratio_by_period do
            fields = %w[org_managers_ratio total_managers]
            fetch_metric_data_v2(OrganizationalGovernanceMetric, fields)
          end
        end
      end
    end
  end
end
