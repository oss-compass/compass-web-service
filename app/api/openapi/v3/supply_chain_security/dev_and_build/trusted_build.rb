# frozen_string_literal: true


module Openapi
  module V3
    module SupplyChainSecurity
      module DevAndBuild
        class TrustedBuild < Grape::API
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

          resource :trusted_build do
            desc 'Build Success / 可构建',
                 detail: 'Verify the project can be built from source using publicly available tools / 验证项目能否使用公开工具从源码成功构建出可工作的系统。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Trusted Build / 可信构建'
                 ],
                 success: { code: 201, model: Openapi::Entities::TrustedBuildSuccessResponse }
            params { use :metric_search }
            post :trusted_build_success do
              fields = %w[
                ecology_build_success_rate
                build_checker_present
              ]
              fetch_metric_data_v2(TrustedBuildMetric, fields)
            end

            desc 'CI Integration / CI集成',
                 detail: 'Check whether CI pipeline is configured and enabled / 检查项目是否配置并启用了自动化的持续集成流水线。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Trusted Build / 可信构建'
                 ],
                 success: { code: 201, model: Openapi::Entities::CiIntegrationResponse }
            params { use :metric_search }
            post :ci_integration do
              fields = %w[
                ecology_ci
                ci_integration
              ]
              fetch_metric_data_v2(TrustedBuildMetric, fields)
            end

            desc 'Build Metadata Available / 构建元数据可获取',
                 detail: 'Check whether input metadata required for build is provided / 检查是否保存并提供了构建过程的输入元数据（环境、版本等）。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Trusted Build / 可信构建'
                 ],
                 success: { code: 201, model: Openapi::Entities::BuildMetadataAvailableResponse }
            params { use :metric_search }
            post :build_metadata_available do
              fields = %w[
                build_metadata_available
                detail
              ]
              fetch_metric_data_v2(TrustedBuildMetric, fields)
            end

            desc 'Reproducible Build / 一致性构建',
                 detail: 'Verify the same source produces identical artifact checksum in the same environment / 验证在相同环境下，同一源码是否能产出Hash值完全一致的二进制包。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Trusted Build / 可信构建'
                 ],
                 success: { code: 201, model: Openapi::Entities::ReproducibleBuildResponse }
            params { use :metric_search }
            post :reproducible_build do
              fields = %w[
                reproducible_build
              ]
              fetch_metric_data_v2(TrustedBuildMetric, fields)
            end

            desc 'Trusted Build Model Data / 可信构建模型数据',
                 detail: 'Trusted Build Model Data / 可信构建模型数据',
                 tags: [
                   'V3 API',
                   'Metrics Model Data / 模型数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Trusted Build / 可信构建'
                 ],
                 success: { code: 201, model: Openapi::Entities::TrustedBuildModelDataResponse }
            params { use :metric_search }
            post :model_data do
              fields = %w[
                ecology_build_success_rate
                build_checker_present
                ecology_ci
                ci_integration
                build_metadata_available
                detail
                reproducible_build
                score
              ]
              fetch_metric_data_v2(TrustedBuildMetric, fields)
            end
          end


        end
      end
    end
  end
end
