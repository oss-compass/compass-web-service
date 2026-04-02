# frozen_string_literal: true

module Openapi
  module V3
    module CommunityHealth
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

            desc 'Individual Code Contributors by Period / 个人代码贡献者数量',
                 detail: 'Number of individual (non-org) contributors with code contributions during the period / 周期内有代码贡献行为的个人贡献者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Personal Governance / 个人开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::IndividualCodeContributorsResponse }
            params { use :metric_search }
            post :individual_code_contributors_by_period do
              fetch_metric_data_v2(PersonalGovernanceMetric, 'individual_code_contributors')
            end

            desc 'Individual Code Contributors Ratio by Period / 个人代码贡献者占比',
                 detail: 'Ratio of individual code contributors to total code contributors in the period / 周期内个人代码贡献者数量占总代码贡献者数量的比例',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Personal Governance / 个人开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::IndividualCodeContributorsRatioResponse }
            params { use :metric_search }
            post :individual_code_contributors_ratio_by_period do
              fields = %w[individual_code_contributors_ratio total_code_contributors]
              fetch_metric_data_v2(PersonalGovernanceMetric, fields)
            end

            desc 'Individual Code Contribution by Period / 个人代码贡献量',
                 detail: 'Lines of code contributed by individuals during the period / 周期内个人贡献者提交的代码行数',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Personal Governance / 个人开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::IndividualCodeContributionResponse }
            params { use :metric_search }
            post :individual_code_contribution_by_period do
              fetch_metric_data_v2(PersonalGovernanceMetric, 'individual_code_contribution')
            end

            desc 'Individual Code Contribution Ratio by Period / 个人代码贡献量占比',
                 detail: 'Ratio of individual code contribution to total code contribution in the period / 周期内个人贡献的代码行数占总代码贡献行数的比例',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Personal Governance / 个人开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::IndividualCodeContributionRatioResponse }
            params { use :metric_search }
            post :individual_code_contribution_ratio_by_period do
              fields = %w[individual_code_contribution_ratio total_code_contribution]
              fetch_metric_data_v2(PersonalGovernanceMetric, fields)
            end

            desc 'Individual Non-code Contributors by Period / 个人非代码贡献者数量',
                 detail: 'Number of individual contributors with non-code contributions only during the period / 周期内仅参与非代码贡献的个人贡献者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Personal Governance / 个人开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::IndividualNonCodeContributorsResponse }
            params { use :metric_search }
            post :individual_non_code_contributors_by_period do
              fetch_metric_data_v2(PersonalGovernanceMetric, 'individual_non_code_contributors')
            end

            desc 'Individual Non-code Contributors Ratio by Period / 个人非代码贡献者占比',
                 detail: 'Ratio of individual non-code contributors to total non-code contributors in the period / 周期内个人非代码贡献者数量占总非代码贡献者数量的比例',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Personal Governance / 个人开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::IndividualNonCodeContributorsRatioResponse }
            params { use :metric_search }
            post :individual_non_code_contributors_ratio_by_period do
              fields = %w[individual_non_code_contributors_ratio total_non_code_contributors]
              fetch_metric_data_v2(PersonalGovernanceMetric, fields)
            end

            desc 'Individual Non-code Contribution by Period / 个人非代码贡献量',
                 detail: 'Total non-code contribution count by individuals (e.g. Issue/PR comments) during the period / 周期内个人贡献者提交的非代码贡献总次数（如 Issue/PR 评论数）',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Personal Governance / 个人开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::IndividualNonCodeContributionResponse }
            params { use :metric_search }
            post :individual_non_code_contribution_by_period do
              fetch_metric_data_v2(PersonalGovernanceMetric, 'individual_non_code_contribution')
            end

            desc 'Individual Non-code Contribution Ratio by Period / 个人非代码贡献量占比',
                 detail: 'Ratio of individual non-code contribution to total non-code contribution in the period / 周期内个人非代码贡献量占非代码总贡献量的比例',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Personal Governance / 个人开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::IndividualNonCodeContributionRatioResponse }
            params { use :metric_search }
            post :individual_non_code_contribution_ratio_by_period do
              fields = %w[individual_non_code_contribution_ratio total_non_code_contribution]
              fetch_metric_data_v2(PersonalGovernanceMetric, fields)
            end

            desc 'Individual Managers by Period / 个人管理者数量',
                 detail: 'Number of distinct individual managers in governance roles during the period / 周期内来自个人的去重管理者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Personal Governance / 个人开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::IndividualManagersResponse }
            params { use :metric_search }
            post :individual_managers_by_period do
              fetch_metric_data_v2(PersonalGovernanceMetric, 'individual_managers')
            end

            desc 'Individual Managers Ratio by Period / 个人管理者数量占比',
                 detail: 'Ratio of individual managers to total managers in the period / 周期内个人管理者数量占总管理者数量的比例',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Development Governance / 开放治理',
                   'Personal Governance / 个人开放治理'
                 ],
                 success: { code: 201, model: Openapi::Entities::IndividualManagersRatioResponse }
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
end
