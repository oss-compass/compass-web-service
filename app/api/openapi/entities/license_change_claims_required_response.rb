# frozen_string_literal: true
module Openapi
  module Entities

    class LicenseChangeClaimsRequiredMetricDetail < Grape::Entity
      expose :license_change_claims_required, documentation: {
        type: 'Integer',
        desc: 'Software Change Declaration Required (0: No, 1: Yes) / 是否要求声明软件变更（0：不需要，1：需要）',
        example: 1
      }
      expose :license_list, documentation: {
        type: 'String', is_array: true,
        desc: 'All Licenses List / 所有许可证列表',
        example: ['GPL-3.0', 'MIT', 'Apache-2.0']
      }
      expose :licenses_requiring_claims, documentation: {
        type: 'String', is_array: true,
        desc: 'Licenses Requiring Change Declaration / 需要声明变更的许可证列表',
        example: ['GPL-3.0']
      }
      expose :license_change_claims_required_details, documentation: {
        type: 'String',
        desc: 'Detailed Description / 详细说明',
        example: 'Requires declaration of software changes'
      }
    end

    class LicenseChangeClaimsRequiredItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'Unique ID / 唯一id', example: "a0ddde9c5ad5c6956e5a9662cc4859ad1abaf8b1" }
      expose :level, documentation: { type: 'String', desc: 'Repository Level: repo/community / 仓库层级: 仓库repo/社区community', example: "repo" }
      expose :label, documentation: { type: 'String', desc: 'Repository or Community Label / 仓库或社区标签', example: "https://github.com/oss-compass/compass-web-service" }
      expose :metric_type, documentation: { type: 'String', desc: 'Metric Type / 指标类型', example: "community_portrait" }
      expose :metric_name, documentation: { type: 'String', desc: 'Metric Name / 指标名称', example: "License Change Declaration Requirement Check/许可证变更声明要求检查" }
      expose :metric_detail, using: Entities::LicenseChangeClaimsRequiredMetricDetail, documentation: {
        type: 'Entities::LicenseChangeClaimsRequiredMetricDetail',
        desc: 'Metric Details / 指标详情',
        param_type: 'body'
      }
      expose :version_number, documentation: { type: 'String', desc: 'Version Number / 版本号', example: "v2.0.0" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'Time / 时间', example: "2023-04-12T06:18:01+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T03:27:03.506703+00:00" }
    end

    class LicenseChangeClaimsRequiredResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::LicenseChangeClaimsRequiredItem, documentation: {
        type: 'Entities::LicenseChangeClaimsRequiredItem',
        desc: 'response',
        param_type: 'body',
        is_array: true
      }
    end

  end
end
