# frozen_string_literal: true

module Openapi
  module V2
    module L2
      class SoftwareArtifactPortrait < Grape::API
        version 'v2', using: :path
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
        resource :software_artifact_portrait do

          # 仓库
          desc 'Repository Document Count / 仓库文档数量',
               detail: 'Evaluate the number of project documents / 评估项目文档的数量',
               tags: ['Metrics Data / 指标数据', 'Software Artifact Persona / 软件制品画像'],
               success: {
                 code: 201, model: Openapi::Entities::DocNumberResponse
               }
          params {
            use :software_artifact_portrait_search
          }
          post :doc_number do
            fetch_metric_data(metric_name: "doc_number", version_number: params[:version_number])
          end

          desc 'Repository Document Quality / 仓库文档质量',
               detail: 'Evaluate the quantity and quality of documentation support / 评估说明文档的数量、质量等支持情况',
               tags: ['Metrics Data / 指标数据', 'Software Artifact Persona / 软件制品画像'],
               success: {
                 code: 201, model: Openapi::Entities::DocQuartyResponse
               }
          params {
            use :software_artifact_portrait_search
          }
          post :doc_quarty do
            fetch_metric_data(metric_name: "doc_quarty", version_number: params[:version_number])
          end

          desc 'Chinese Documentation Support / 仓库中文文档支持度',
               detail: 'Evaluate Chinese language support / 评估是否有中文支持。',
               tags: ['Metrics Data / 指标数据', 'Software Artifact Persona / 软件制品画像'],
               success: {
                 code: 201, model: Openapi::Entities::ZhFilesNumberResponse
               }
          params {
            use :software_artifact_portrait_search
          }
          post :zh_files_number do
            fetch_metric_data(metric_name: "zh_files_number", version_number: params[:version_number])
          end

          desc 'Open Source License Compatibility / 仓库开源许可证兼容性',
               detail: 'Evaluate compatibility between open source licenses / 评估开源项目的开源许可证之间是否兼容。',
               tags: ['Metrics Data / 指标数据', 'Software Artifact Persona / 软件制品画像'],
               success: {
                 code: 201, model: Openapi::Entities::LicenseConflictsExistResponse
               }
          params {
            use :software_artifact_portrait_search
          }
          post :license_conflicts_exist do
            fetch_metric_data(metric_name: "license_conflicts_exist", version_number: params[:version_number])
          end

          desc 'Dependency Compatibility / 仓库依赖兼容性',
               detail: 'Check compatibility between open source software and dependencies / 开源软件和依赖软件是否兼容。',
               tags: ['Metrics Data / 指标数据', 'Software Artifact Persona / 软件制品画像'],
               success: {
                 code: 201, model: Openapi::Entities::LicenseDepConflictsExistResponse
               }
          params {
            use :software_artifact_portrait_search
          }
          post :license_dep_conflicts_exist do
            fetch_metric_data(metric_name: "license_dep_conflicts_exist", version_number: params[:version_number])
          end

          # 安全
          desc 'Vulnerability Response Time / 漏洞响应时间',
               detail: 'Average vulnerability response time for the past five versions / 过去五个版本的漏洞平均响应时间',
               tags: ['Metrics Data / 指标数据', 'Software Artifact Persona / 软件制品画像'],
               success: {
                 code: 201, model: Openapi::Entities::VulDetectTimeResponse
               }
          params {
            use :software_artifact_portrait_search
          }
          post :vul_detect_time do
            fetch_metric_data(metric_name: "vul_detect_time", version_number: params[:version_number])
          end

          desc 'Vulnerability Feedback Information / 漏洞反馈信息',
               detail: 'Check for vulnerability feedback methods and paths / 是否含有漏洞的反馈方式，以及反馈方式路径。',
               tags: ['Metrics Data / 指标数据', 'Software Artifact Persona / 软件制品画像'],
               success: {
                 code: 201, model: Openapi::Entities::VulnerabilityFeedbackChannelsResponse
               }
          params {
            use :software_artifact_portrait_search
          }
          post :vulnerability_feedback_channels do
            fetch_metric_data(metric_name: "vulnerability_feedback_channels", version_number: params[:version_number])
          end

          desc 'Security Vulnerability Count / 安全漏洞数',
               detail: 'Number of security vulnerabilities / 安全漏洞数',
               tags: ['Metrics Data / 指标数据', 'Software Artifact Persona / 软件制品画像'],
               success: {
                 code: 201, model: Openapi::Entities::SecurityVulStatResponse
               }
          params {
            use :software_artifact_portrait_search
          }
          post :security_vul_stat do
            fetch_metric_data(metric_name: "security_vul_stat", version_number: params[:version_number])
          end

          desc 'Security Vulnerability Level / 安全漏洞等级',
               detail: 'Evaluate security vulnerability levels of open source software / 评估开源软件的安全漏洞等级。',
               tags: ['Metrics Data / 指标数据', 'Software Artifact Persona / 软件制品画像'],
               success: {
                 code: 201, model: Openapi::Entities::VulLevelsResponse
               }
          params {
            use :software_artifact_portrait_search
          }
          post :vul_levels do
            fetch_metric_data(metric_name: "vul_levels", version_number: params[:version_number])
          end

          desc 'Security Vulnerability Fix Status / 安全漏洞修复情况',
               detail: 'Check if exposed security vulnerabilities have been fixed / 核查已暴露的安全漏洞是否已修复。',
               tags: ['Metrics Data / 指标数据', 'Software Artifact Persona / 软件制品画像'],
               success: {
                 code: 201, model: Openapi::Entities::SecurityVulFixedResponse
               }
          params {
            use :software_artifact_portrait_search
          }
          post :security_vul_fixed do
            fetch_metric_data(metric_name: "security_vul_fixed", version_number: params[:version_number])
          end

          # 代码
          desc 'Code Scan Records / 代码扫描记录',
               detail: 'Check for code scanning records / 核查是否有代码扫描记录',
               tags: ['Metrics Data / 指标数据', 'Software Artifact Persona / 软件制品画像'],
               success: {
                 code: 201, model: Openapi::Entities::SecurityScannedResponse
               }
          params {
            use :software_artifact_portrait_search
          }
          post :security_scanned do
            fetch_metric_data(metric_name: "security_scanned", version_number: params[:version_number])
          end

          desc 'Code Readability / 代码可读性',
               detail: 'Evaluate code readability (module division/code comments etc.) / 评估代码可读性（模块划分/代码注释等）。',
               tags: ['Metrics Data / 指标数据', 'Software Artifact Persona / 软件制品画像'],
               success: {
                 code: 201, model: Openapi::Entities::CodeReadabilityResponse
               }
          params {
            use :software_artifact_portrait_search
          }
          post :code_readability do
            fetch_metric_data(metric_name: "code_readability", version_number: params[:version_number])
          end

        end
      end

    end
  end
end
