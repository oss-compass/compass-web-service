# frozen_string_literal: true


module Openapi
  module V3
    module SupplyChainSecurity
      module DevAndBuild
        class DevelopmentDocumentQuality < Grape::API
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

          resource :development_document_quality do
            desc 'README Document Quality / README',
                 detail: 'Check repository has README and clearly describes project functionality / 检查仓库是否包含README文档，且清晰描述了项目功能。',
                 tags: [
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Development Document Quality / 开发文档质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::EcologyReadmeResponse }
            params { use :metric_search }
            post :ecology_readme do
              fields = %w[
                ecology_readme
                ecology_readme_detail
                readme_completeness_score
                ecology_readme_raw
              ]
              fetch_metric_data_v2(DevelopmentDocumentQualityMetric, fields)
            end

            desc 'Build Document / 构建文档',
                 detail: 'Check build/install instructions exist (keywords: Build, Install) / 检查是否提供指导用户从源码编译/安装项目的文档说明。',
                 tags: [
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Development Document Quality / 开发文档质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::EcologyBuildDocResponse }
            params { use :metric_search }
            post :ecology_build_doc do
              fields = %w[
                ecology_build_doc
                ecology_build_doc_detail
                has_build_install_docs
                
              ]
              fetch_metric_data_v2(DevelopmentDocumentQualityMetric, fields)
            end

            desc 'Interface Document / 接口文档',
                 detail: 'Check API docs exist (docs directory or swagger/openapi files) / 检查是否提供清晰的API接口定义文档或规范文件。',
                 tags: [
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Development Document Quality / 开发文档质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::EcologyInterfaceDocResponse }
            params { use :metric_search }
            post :ecology_interface_doc do
              fields = %w[
                ecology_interface_doc
                ecology_interface_doc_detail
                has_api_docs

              ]
              fetch_metric_data_v2(DevelopmentDocumentQualityMetric, fields)
            end

            desc 'Committers File / Committers文件',
                 detail: 'Check OWNERS/MAINTAINERS file exists to list decision-makers / 检查是否公开维护具备决策权的核心贡献者名单（OWNERS/MAINTAINERS）。',
                 tags: [
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Dev and Build / 开发与构建',
                   'Development Document Quality / 开发文档质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::EcologyMaintainerDocResponse }
            params { use :metric_search }
            post :ecology_maintainer_doc do
              fields = %w[
                committers_file_exists
              ]
              fetch_metric_data_v2(DevelopmentDocumentQualityMetric, fields)
            end
          end


        end
      end
    end
  end
end
