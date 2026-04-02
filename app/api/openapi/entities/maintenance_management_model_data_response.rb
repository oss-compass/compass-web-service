# frozen_string_literal: true

module Openapi
  module Entities
    class MaintenanceManagementModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :lifecycle_statement, documentation: { type: 'String', desc: 'Lifecycle statement / 生命周期申明', nullable: true }
      expose :lifecycle_statement_exists, documentation: { type: 'Boolean', desc: 'Lifecycle statement exists / 是否存在生命周期申明', nullable: true }
      expose :lifecycle_statement_detail, documentation: { type: 'String', desc: 'Lifecycle statement detail / 生命周期申明详情', nullable: true }
      expose :avg_vulnerability_fix_days, documentation: { type: 'Float', desc: 'Avg vulnerability fix days / 安全漏洞平均修复时间', nullable: true }
      expose :avg_vulnerability_fix_unavailable, documentation: { type: 'Boolean', desc: 'Avg vulnerability fix unavailable / 安全漏洞平均修复时间是否不可用', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Maintenance Management 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class MaintenanceManagementModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::MaintenanceManagementModelDataItem,
             documentation: { type: 'MaintenanceManagementModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end