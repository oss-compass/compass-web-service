# frozen_string_literal: true


module Openapi
  module V3
    module SupplyChainSecurity
      module DevAndBuild
        class CodeReviewQuality < Grape::API
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
          # before { save_tracking_api! }

          resource :code_review_quality do
            desc 'Dependency Reachable / 依赖可获得',
                 detail: 'Verify third-party dependencies are publicly reachable and downloadable / 验证项目依赖的所有第三方库是否均可公开访问和下载。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Code Review Quality / 代码审查质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::DependencyReachableResponse }
            params { use :metric_search }
            post :dependency_reachable do
              fields = %w[
                dependency_reachable_ok
                dependency_unreachable_list
                detail
              ]
              fetch_metric_data_v2(CodeReviewQualityMetric, fields)
            end

            desc 'Snippet Reference Compliance / 片段引用',
                 detail: 'Detect external code snippets and validate license/copyright source statement compliance / 识别引用的外部代码片段，并验证其来源声明的合规性。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Code Review Quality / 代码审查质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::ComplianceSnippetReferenceResponse }
            params { use :metric_search }
            post :compliance_snippet_reference do
              fields = %w[
                compliance_snippet_reference
                compliance_snippet_reference_detail
                violation_count
              ]
              fetch_metric_data_v2(CodeReviewQualityMetric, fields)
            end

            desc 'Patent Risk (OIN) / 专利风险',
                 detail: 'Analyze patent infringement risk based on OIN list / 基于OIN列表分析引入依赖的专利风险。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Code Review Quality / 代码审查质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::PatentRiskOinResponse }
            params { use :metric_search }
            post :patent_risk_oin do
              fields = %w[
                patent_risk_level
                patent_risk_unavailable
                patent_risk_detail
              ]
              fetch_metric_data_v2(CodeReviewQualityMetric, fields)
            end

            desc 'Test Coverage / 测试覆盖度',
                 detail: 'Measure automated test coverage ratio based on CI coverage report / 衡量自动化测试覆盖率。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Code Review Quality / 代码审查质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::EcologyTestCoverageResponse }
            params { use :metric_search }
            post :ecology_test_coverage do
              fields = %w[
                ecology_test_coverage
                ecology_test_coverage_detail
                test_coverage_percent
                ecology_test_coverage_raw
              ]
              fetch_metric_data_v2(CodeReviewQualityMetric, fields)
            end

            desc 'Code Review Quality Model Data / 代码审查质量模型数据',
                 detail: 'Code Review Quality Model Data / 代码审查质量模型数据',
                 tags: [
                   'V3 API',
                   'Metrics Model Data / 模型数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Code Review Quality / 代码审查质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::CodeReviewQualityModelDataResponse }
            params { use :metric_search }
            post :model_data do
              fields = %w[
                dependency_reachable_ok
                dependency_unreachable_list
                detail
                compliance_snippet_reference
                compliance_snippet_reference_detail
                violation_count
                patent_risk_level
                patent_risk_unavailable
                patent_risk_detail
                ecology_test_coverage
                ecology_test_coverage_detail
                test_coverage_percent
                ecology_test_coverage_raw
                score
              ]
              fetch_metric_data_v2(CodeReviewQualityMetric, fields)
            end
          end


        end
      end
    end
  end
end
