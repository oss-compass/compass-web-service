# frozen_string_literal: true

module Openapi
  module V2
    module L2
      class SoftwareArtifactPortrait < Grape::API
        version 'v2', using: :path
        prefix :api
        format :json

        before { require_login! }
        helpers Openapi::SharedParams::CustomMetricSearch

        resource :software_artifact_portrait do
          desc '文档数量: 评估项目文档的数量',
               detail: 'doc_number / 文档数量',
               tags: ['L2 Portrait/Metric data', 'Software Artifact Portrait']
          params {
            optional :version_number, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.3' }
            use :custom_metric_search
          }
          post :doc_number do
            fetch_metric_data(metric_name: "doc_number", version_number: params[:version_number])
          end

          desc '文档质量: 评估说明文档的数量、质量等支持情况',
               detail: 'doc_quarty / 文档质量',
               tags: ['L2 Portrait/Metric data', 'Software Artifact Portrait']
          params {
            optional :version_number, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.3' }
            use :custom_metric_search
          }
          post :doc_quarty do
            fetch_metric_data(metric_name: "doc_quarty", version_number: params[:version_number])
          end

          desc '漏洞响应时间: 过去五个版本的漏洞平均响应时间',
               detail: 'vul_detect_time / 漏洞响应时间',
               tags: ['L2 Portrait/Metric data', 'Software Artifact Portrait']
          params {
            optional :version_number, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.3' }
            use :custom_metric_search
          }
          post :vul_detect_time do
            fetch_metric_data(metric_name: "vul_detect_time", version_number: params[:version_number])
          end

          desc '安全漏洞数',
               detail: 'security_vul_stat / 安全漏洞数',
               tags: ['L2 Portrait/Metric data', 'Software Artifact Portrait']
          params {
            optional :version_number, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.3' }
            use :custom_metric_search
          }
          post :security_vul_stat do
            fetch_metric_data(metric_name: "security_vul_stat", version_number: params[:version_number])
          end

          desc '代码扫描记录: 核查是否有代码扫描记录',
               detail: 'security_scanned / 代码扫描记录',
               tags: ['L2 Portrait/Metric data', 'Software Artifact Portrait']
          params {
            optional :version_number, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.3' }
            use :custom_metric_search
          }
          post :security_scanned do
            fetch_metric_data(metric_name: "security_scanned", version_number: params[:version_number])
          end

          desc '中文文档支持度: 评估是否有中文支持。',
               detail: 'zh_files_number / 中文文档支持度',
               tags: ['L2 Portrait/Metric data', 'Software Artifact Portrait']
          params {
            optional :version_number, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.3' }
            use :custom_metric_search
          }
          post :zh_files_number do
            fetch_metric_data(metric_name: "zh_files_number", version_number: params[:version_number])
          end

          desc '安全漏洞等级: 评估开源软件的安全漏洞等级。',
               detail: 'vul_levels / 安全漏洞等级',
               tags: ['L2 Portrait/Metric data', 'Software Artifact Portrait']
          params {
            optional :version_number, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.3' }
            use :custom_metric_search
          }
          post :vul_levels do
            fetch_metric_data(metric_name: "vul_levels", version_number: params[:version_number])
          end

          desc '漏洞反馈信息: 是否含有漏洞的反馈方式，以及反馈方式路径。',
               detail: 'vulnerability_feedback_channels / 漏洞反馈信息',
               tags: ['L2 Portrait/Metric data', 'Software Artifact Portrait']
          params {
            optional :version_number, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.3' }
            use :custom_metric_search
          }
          post :vulnerability_feedback_channels do
            fetch_metric_data(metric_name: "vulnerability_feedback_channels", version_number: params[:version_number])
          end

          desc '代码可读性: 评估代码可读性（模块划分/代码注释等）。',
               detail: 'code_readability / 代码可读性',
               tags: ['L2 Portrait/Metric data', 'Software Artifact Portrait']
          params {
            optional :version_number, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.3' }
            use :custom_metric_search
          }
          post :code_readability do
            fetch_metric_data(metric_name: "code_readability", version_number: params[:version_number])
          end

          desc '安全漏洞修复情况: 核查已暴露的安全漏洞是否已修复。',
               detail: 'security_vul_fixed / 安全漏洞修复情况',
               tags: ['L2 Portrait/Metric data', 'Software Artifact Portrait']
          params {
            optional :version_number, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.3' }
            use :custom_metric_search
          }
          post :security_vul_fixed do
            fetch_metric_data(metric_name: "security_vul_fixed", version_number: params[:version_number])
          end

          desc '开源许可证兼容性: 评估开源项目的开源许可证之间是否兼容。',
               detail: 'license_conflicts_exist / 开源许可证兼容性',
               tags: ['L2 Portrait/Metric data', 'Software Artifact Portrait']
          params {
            optional :version_number, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.3' }
            use :custom_metric_search
          }
          post :license_conflicts_exist do
            fetch_metric_data(metric_name: "license_conflicts_exist", version_number: params[:version_number])
          end

          desc '依赖兼容性: 开源软件和依赖软件是否兼容。',
               detail: 'license_dep_conflicts_exist / 依赖兼容性',
               tags: ['L2 Portrait/Metric data', 'Software Artifact Portrait']
          params {
            optional :version_number, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.3' }
            use :custom_metric_search
          }
          post :license_dep_conflicts_exist do
            fetch_metric_data(metric_name: "license_dep_conflicts_exist", version_number: params[:version_number])
          end

        end
      end

    end
  end
end
