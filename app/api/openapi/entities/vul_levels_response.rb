# frozen_string_literal: true
module Openapi
  module Entities

    class VulLevelsCount < Grape::Entity
      expose :high, documentation: { type: 'Integer', desc: '高危漏洞数量', example: 5 }
      expose :medium, documentation: { type: 'Integer', desc: '中危漏洞数量', example: 8 }
      expose :low, documentation: { type: 'Integer', desc: '低危漏洞数量', example: 3 }
    end

    class VulLevelDetail < Grape::Entity
      expose :package_name, documentation: { type: 'String', desc: '漏洞包名', example: 'log4j-core' }
      expose :package_version, documentation: { type: 'String', desc: '漏洞版本信息', example: '2.14.1' }
      expose :vulnerabilities, documentation: { type: 'Array', desc: '漏洞的编号（CVE）', example: ['CVE-2021-44228', 'CVE-2021-45046'] }
      expose :severity, documentation: { type: 'String', desc: '修复等级', example: 'high' }
    end

    class VulLevelsMetricDetail < Grape::Entity
      expose :vul_levels, documentation: { type: 'Integer', desc: '漏洞总数', example: 16 }
      expose :vul_levels_count, using: Entities::VulLevelsCount, documentation: { type: 'Entities::VulLevelsCount', desc: '各等级漏洞数量', param_type: 'body' }
      expose :vul_level_details, using: Entities::VulLevelDetail, documentation: {
        type: 'Array',
        desc: '漏洞详细信息列表',
        param_type: 'body',
        is_array: true
      }
    end

    class VulLevelsItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: '唯一id', example: "a0ddde9c5ad5c6956e5a9662cc4859ad1abaf8b1" }
      expose :level, documentation: { type: 'String', desc: '仓库层级: 仓库repo/社区community', example: "repo" }
      expose :label, documentation: { type: 'String', desc: '仓库或社区标签', example: "https://github.com/oss-compass/compass-web-service" }
      expose :metric_type, documentation: { type: 'String', desc: '指标类型', example: "software_artifact_portrait" }
      expose :metric_name, documentation: { type: 'String', desc: '指标名称', example: "安全漏洞等级" }
      expose :metric_detail, using: Entities::VulLevelsMetricDetail, documentation: { type: 'Entities::VulLevelsMetricDetail', desc: '指标详情', param_type: 'body'}
      expose :version_number, documentation: { type: 'String', desc: '版本号', example: "v2.0.0" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: '时间', example: "2023-04-12T06:18:01+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T03:27:03.506703+00:00" }
    end

    class VulLevelsResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::VulLevelsItem, documentation: {
        type: 'Entities::VulLevelsItem',
        desc: 'response',
        param_type: 'body',
        is_array: true
      }
    end

  end
end
