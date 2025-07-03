# frozen_string_literal: true
module Openapi
  module Entities

    class SecurityScannedMetricDetail < Grape::Entity
      expose :security_scanned, documentation: { type: 'Integer', desc: '是否有扫描数据（0或1）', example: 1 }
      expose :scanner, documentation: { type: 'String', desc: '使用的扫描工具名称', example: 'osv scanner' }
      expose :info, documentation: { type: 'String', desc: '额外信息', example: '最近一次扫描时间：2025-01-20' }
    end

    class SecurityScannedItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: '唯一id', example: "a0ddde9c5ad5c6956e5a9662cc4859ad1abaf8b1" }
      expose :level, documentation: { type: 'String', desc: '仓库层级: 仓库repo/社区community', example: "repo" }
      expose :label, documentation: { type: 'String', desc: '仓库或社区标签', example: "https://github.com/oss-compass/compass-web-service" }
      expose :metric_type, documentation: { type: 'String', desc: '指标类型', example: "software_artifact_portrait" }
      expose :metric_name, documentation: { type: 'String', desc: '指标名称', example: "代码扫描记录" }
      expose :metric_detail, using: Entities::SecurityScannedMetricDetail, documentation: { type: 'Entities::SecurityScannedMetricDetail', desc: '指标详情', param_type: 'body'}
      expose :version_number, documentation: { type: 'String', desc: '版本号', example: "v2.0.0" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: '时间', example: "2023-04-12T06:18:01+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T03:27:03.506703+00:00" }
    end

    class SecurityScannedResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::SecurityScannedItem, documentation: {
        type: 'Entities::SecurityScannedItem',
        desc: 'response',
        param_type: 'body',
        is_array: true
      }
    end

  end
end
