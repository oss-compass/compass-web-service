# frozen_string_literal: true
module Openapi
  module Entities

    class LicenseIsWeakMetricDetail < Grape::Entity
      expose :license_is_weak, documentation: { type: 'Integer', desc: '是否为宽松型许可证（0或1）', example: 1 }
      expose :license_list, documentation: { type: 'Array', desc: '许可证列表', example: ['MIT', 'Apache-2.0'] }
      expose :details, documentation: { type: 'String', desc: '详细信息', example: '项目使用MIT许可证，属于宽松型开源许可证' }
    end

    class LicenseIsWeakItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: '唯一id', example: "a0ddde9c5ad5c6956e5a9662cc4859ad1abaf8b1" }
      expose :level, documentation: { type: 'String', desc: '仓库层级: 仓库repo/社区community', example: "repo" }
      expose :label, documentation: { type: 'String', desc: '仓库或社区标签', example: "https://github.com/oss-compass/compass-web-service" }
      expose :metric_type, documentation: { type: 'String', desc: '指标类型', example: "community_portrait" }
      expose :metric_name, documentation: { type: 'String', desc: '指标名称', example: "仓库宽松型或弱著作权开源许可证" }
      expose :metric_detail, using: Entities::LicenseIsWeakMetricDetail, documentation: { type: 'Entities::LicenseIsWeakMetricDetail', desc: '指标详情', param_type: 'body'}
      expose :version_number, documentation: { type: 'String', desc: '版本号', example: "v2.0.0" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: '时间', example: "2023-04-12T06:18:01+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T03:27:03.506703+00:00" }
    end

    class LicenseIsWeakResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::LicenseIsWeakItem, documentation: {
        type: 'Entities::LicenseIsWeakItem',
        desc: 'response',
        param_type: 'body',
        is_array: true
      }
    end

  end
end
