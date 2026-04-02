# frozen_string_literal: true


module Openapi
  module V3
    module SupplyChainSecurity
      module ReleaseAndMaintenance
        class ReleaseQuality < Grape::API
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

          resource :release_quality do
            desc 'SBOM in Release / SBOM检查',
                 detail: 'Verify SBOM file exists in release assets (SPDX/CycloneDX) / 验证发布的软件版本中是否包含标准的软件物料清单（SPDX/CycloneDX格式）。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Release and Maintenance / 发布与维护',
                   'Release Quality / 发布质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::SbomInReleaseResponse }
            params { use :metric_search }
            post :sbom_in_release do
              fields = %w[sbom_in_release detail]
              fetch_metric_data_v2(ReleaseQualityMetric, fields)
            end

            desc 'Binary Artifacts in Repo / 二进制制品包含',
                 detail: 'Check whether repository contains prohibited compiled binary artifacts / 检查源码仓库中是否违规包含了编译后的二进制文件。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Release and Maintenance / 发布与维护',
                   'Release Quality / 发布质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::SecurityBinaryArtifactResponse }
            params { use :metric_search }
            post :security_binary_artifact do
              fields = %w[
                security_binary_artifact
                security_binary_artifact_detail
                binary_violation_files
                binary_archive_list
                security_binary_artifact_raw
              ]
              fetch_metric_data_v2(ReleaseQualityMetric, fields)
            end

            desc 'Package Signature / 软件包签名',
                 detail: 'Verify released package is digitally signed to ensure integrity / 验证发布的软件包是否经过数字签名以确保完整性和防篡改。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Release and Maintenance / 发布与维护',
                   'Release Quality / 发布质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::SecurityPackageSigResponse }
            params { use :metric_search }
            post :security_package_sig do
              fields = %w[security_package_sig]
              fetch_metric_data_v2(ReleaseQualityMetric, fields)
            end

            desc 'Release Notes / Release Notes',
                 detail: 'Check release notes are provided with clear change descriptions / 检查版本发布时是否提供了清晰的变更说明文档。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Release and Maintenance / 发布与维护',
                   'Release Quality / 发布质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::LifecycleReleaseNoteResponse }
            params { use :metric_search }
            post :lifecycle_release_note do
              fields = %w[lifecycle_release_note]
              fetch_metric_data_v2(ReleaseQualityMetric, fields)
            end

            desc 'Release Quality Model Data / 发布质量模型数据',
                 detail: 'Release Quality Model Data / 发布质量模型数据',
                 tags: [
                   'V3 API',
                   'Metrics Model Data / 模型数据',
                   'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
                   'Release and Maintenance / 发布与维护',
                   'Release Quality / 发布质量'
                 ],
                 success: { code: 201, model: Openapi::Entities::ReleaseQualityModelDataResponse }
            params { use :metric_search }
            post :model_data do
              fields = %w[
                sbom_in_release
                detail
                security_binary_artifact
                security_binary_artifact_detail
                binary_violation_files
                binary_archive_list
                security_binary_artifact_raw
                security_package_sig
                lifecycle_release_note
                score
              ]
              fetch_metric_data_v2(ReleaseQualityMetric, fields)
            end
          end


        end
      end
    end
  end
end
