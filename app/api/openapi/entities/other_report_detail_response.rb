# frozen_string_literal: true
module Openapi
  module Entities

    class OtherReportDiagramItem < Grape::Entity
      expose :id, documentation: { type: 'Integer', desc: 'attachment id / 附件 id', example: 1 }
      expose :filename, documentation: { type: 'String', desc: 'image filename / 图片文件名', example: 'arch.png' }
      expose :url, documentation: { type: 'String', desc: 'image url / 图片地址', example: 'https://compass.example.com/rails/active_storage/blobs/xxx/arch.png' } do |attachment|
        host = ENV.fetch('DEFAULT_HOST')
        path = Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true)
        "#{host}#{path}"
      end
    end

    class OtherReportMetricDetail < Grape::Entity
      SCORE_COLUMNS = %w[
        base_repo_name base_website_url base_code_url
        compliance_license compliance_dco compliance_package_sig compliance_license_compatibility
        ecology_dependency_acquisition ecology_code_maintenance ecology_community_support
        ecology_adoption_analysis ecology_software_quality ecology_patent_risk
        lifecycle_version_normalization lifecycle_version_number lifecycle_version_lifecycle
        security_binary_artifact security_vulnerability security_vulnerability_response
        security_vulnerability_disclosure security_history_vulnerability
        upstream_collaboration_strategy
      ].freeze

      expose :id, :status, documentation: { type: 'String', desc: 'metric status / 指标状态: progress, again_progress, success' }
      expose(*SCORE_COLUMNS, documentation: { type: 'Integer', desc: 'metric score, 0-10 / 指标得分' })
      expose :details, documentation: { type: 'JSON', desc: 'metric score details(JSON parsed) / 指标得分明细' } do |metric|
        SCORE_COLUMNS.each_with_object({}) do |column, hash|
          raw = metric.try("#{column}_detail")
          next if raw.blank?
          begin
            hash[column] = JSON.parse(raw)
          rescue JSON::ParserError, TypeError
            hash[column] = raw
          end
        end
      end
    end

    class OtherReportDetail < Grape::Entity
      expose :id, :report_type, :short_code, :name
      expose :tpc_software_sig_id
      expose :sig_name, documentation: { type: 'String', desc: 'sig name / SIG 名称' }
      expose :release, :release_time
      expose :manufacturer, :website_url, :code_url, :programming_language
      expose :code_count, :license
      expose :vulnerability_disclosure, :vulnerability_response, :adaptation_method
      expose :oh_commit_sha
      expose :upstream_collaboration_strategy, :upstream_communication_link, :report_category
      expose :user_id
      expose :user_name, documentation: { type: 'String', desc: 'creator user name / 创建人用户名' }
      expose :created_at, :updated_at
      expose :metric, using: Entities::OtherReportMetricDetail, documentation: { type: 'Entities::OtherReportMetricDetail', desc: 'report metric(default version) / 报告指标(默认版本)' } do |report|
        report.tpc_software_report_metrics.where(version: TpcSoftwareReportMetric::Version_Default).first
      end
      expose :architecture_diagrams, using: Entities::OtherReportDiagramItem, documentation: { type: 'Entities::OtherReportDiagramItem', desc: 'architecture diagrams / 架构图列表', is_array: true } do |report|
        report.attachments
      end

      private

      def sig_name
        TpcSoftwareSig.find_by(id: object.tpc_software_sig_id)&.name
      end

      def user_name
        User.find_by(id: object.user_id)&.name
      end
    end

    class OtherReportDetailResponse < Grape::Entity
      expose :status, documentation: { type: 'Boolean', desc: 'status', example: true }
      expose :message, documentation: { type: 'String', desc: 'message', example: '' }
      expose :report, using: Entities::OtherReportDetail, documentation: { type: 'Entities::OtherReportDetail', desc: 'report detail / 报告详情' }
    end

  end
end
