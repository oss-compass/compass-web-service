# frozen_string_literal: true
module Openapi
  module Entities

    class SecurityVulFixedMetricDetail < Grape::Entity
      expose :security_vul_fixed, documentation: { type: 'Integer', desc: 'Number of Fixed Vulnerabilities / 已修复的漏洞数量', example: 15 }
      expose :security_vul_unfixed, documentation: { type: 'Integer', desc: 'Number of Unfixed Vulnerabilities / 未修复的漏洞数量', example: 5 }
      expose :info, documentation: { type: 'String', desc: 'Additional Information / 额外信息', example: 'All high-risk vulnerabilities have been fixed' }
    end

    class SecurityVulFixedItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'Unique ID / 唯一id', example: "a0ddde9c5ad5c6956e5a9662cc4859ad1abaf8b1" }
      expose :level, documentation: { type: 'String', desc: 'Repository Level: repo/community / 仓库层级: 仓库repo/社区community', example: "repo" }
      expose :label, documentation: { type: 'String', desc: 'Repository or Community Label / 仓库或社区标签', example: "https://github.com/oss-compass/compass-web-service" }
      expose :metric_type, documentation: { type: 'String', desc: 'Metric Type / 指标类型', example: "software_artifact_portrait" }
      expose :metric_name, documentation: { type: 'String', desc: 'Metric Name / 指标名称', example: "Security Vulnerability Fix Status" }
      expose :metric_detail, using: Entities::SecurityVulFixedMetricDetail, documentation: { type: 'Entities::SecurityVulFixedMetricDetail', desc: 'Metric Details / 指标详情', param_type: 'body'}
      expose :version_number, documentation: { type: 'String', desc: 'Version Number / 版本号', example: "v2.0.0" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'Time / 时间', example: "2023-04-12T06:18:01+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T03:27:03.506703+00:00" }
    end

    class SecurityVulFixedResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::SecurityVulFixedItem, documentation: {
        type: 'Entities::SecurityVulFixedItem',
        desc: 'response',
        param_type: 'body',
        is_array: true
      }
    end

  end
end
