# frozen_string_literal: true

module Openapi
  module V3
    module DevelopmentGovernance
      class PersonalGovernance < Grape::API
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

        resource :personal_governance do

          desc '个人代码贡献者数量 / Individual Code Contributors by Period',
               detail: '定义：周期内有代码贡献行为（如代码提交、PR）的个人（非组织机构）贡献者数量。输入：周期内有代码贡献的去重用户列表及其所属机构信息。输出：人数（个）。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Personal Governance / 个人开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :individual_code_contributors_by_period do
            fetch_metric_data_v2(PersonalGovernanceMetric, 'individual_code_contributors')
          end

          desc '个人代码贡献者占比 / Individual Code Contributors Ratio by Period',
               detail: '定义：周期内个人代码贡献者数量占总代码贡献者数量的比例。输入：个人代码贡献者数量（分子），周期内总代码贡献者数量（分母）。输出：百分比（%）。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Personal Governance / 个人开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :individual_code_contributors_ratio_by_period do
            fields = %w[individual_code_contributors_ratio total_code_contributors]
            fetch_metric_data_v2(PersonalGovernanceMetric, fields)
          end

          desc '个人代码贡献量 / Individual Code Contribution by Period',
               detail: '定义：周期内个人贡献者提交的代码行数。输入：周期内代码提交详情（包含提交者所属机构信息）。输出：代码行数（Line）。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Personal Governance / 个人开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :individual_code_contribution_by_period do
            fetch_metric_data_v2(PersonalGovernanceMetric, 'individual_code_contribution')
          end

          desc '个人代码贡献量占比 / Individual Code Contribution Ratio by Period',
               detail: '定义：周期内个人贡献的代码行数占总代码贡献行数的比例。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Personal Governance / 个人开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :individual_code_contribution_ratio_by_period do
            fields = %w[individual_code_contribution_ratio total_code_contribution]
            fetch_metric_data_v2(PersonalGovernanceMetric, fields)
          end

          desc '个人非代码贡献者数量 / Individual Non-code Contributors by Period',
               detail: '定义：周期内仅参与非代码贡献行为的个人（非组织机构）贡献者数量。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Personal Governance / 个人开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :individual_non_code_contributors_by_period do
            fetch_metric_data_v2(PersonalGovernanceMetric, 'individual_non_code_contributors')
          end

          desc '个人非代码贡献者占比 / Individual Non-code Contributors Ratio by Period',
               detail: '定义：周期内个人非代码贡献者数量占总非代码贡献者数量的比例。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Personal Governance / 个人开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :individual_non_code_contributors_ratio_by_period do
            fields = %w[individual_non_code_contributors_ratio total_non_code_contributors]
            fetch_metric_data_v2(PersonalGovernanceMetric, fields)
          end

          desc '个人非代码贡献量 / Individual Non-code Contribution by Period',
               detail: '定义：周期内个人贡献者提交的非代码贡献总次数（如 Issue/PR 评论数）。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Personal Governance / 个人开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :individual_non_code_contribution_by_period do
            fetch_metric_data_v2(PersonalGovernanceMetric, 'individual_non_code_contribution')
          end

          desc '个人非代码贡献量占比 / Individual Non-code Contribution Ratio by Period',
               detail: '定义：周期内个人非代码贡献量占非代码总贡献量的比例。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Personal Governance / 个人开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :individual_non_code_contribution_ratio_by_period do
            fields = %w[individual_non_code_contribution_ratio total_non_code_contribution]
            fetch_metric_data_v2(PersonalGovernanceMetric, fields)
          end

          desc '个人管理者数量 / Individual Managers by Period',
               detail: '定义：周期内在社区治理角色中，来自个人的去重管理者数量。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Personal Governance / 个人开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :individual_managers_by_period do
            fetch_metric_data_v2(PersonalGovernanceMetric, 'individual_managers')
          end

          desc '个人管理者数量占比 / Individual Managers Ratio by Period',
               detail: '定义：周期内在社区治理角色中，来自个人的管理者数量占总管理者数量的比例。',
               tags: ['Metrics Data / 指标数据', 'Development Governance / 开放治理', 'Personal Governance / 个人开放治理'],
               success: { code: 201, model: Openapi::Entities::GovernanceMetricResponse }
          params { use :metric_search }
          post :individual_managers_ratio_by_period do
            fields = %w[individual_managers_ratio total_managers]
            fetch_metric_data_v2(PersonalGovernanceMetric, fields)
          end

        end
      end
    end
  end
end
