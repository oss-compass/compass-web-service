# frozen_string_literal: true
module Openapi
  module Entities

    class DashboardAlertRuleItem < Grape::Entity
      expose :id, documentation: { type: 'Integer', desc: '规则ID', example: 1 }
      expose :dashboard_id, documentation: { type: 'Integer', desc: '看板ID', example: 1 }
      expose :monitor_type, documentation: { type: 'String', desc: '监控类型', example: 'community' }
      expose :target_repo, documentation: { type: 'String', desc: '目标仓库', example: 'https://github.com/xxx/xxx' }
      expose :metric_key, documentation: { type: 'String', desc: '监控指标key', example: 'new_issue_count' }
      expose :metric_name, documentation: { type: 'String', desc: '监控指标名称', example: '新建Issue数量' }
      expose :operator, documentation: { type: 'String', desc: '比较运算符', example: '>' }
      expose :operator_type, documentation: { type: 'String', desc: '比较类型', example: 'value' }
      expose :threshold, documentation: { type: 'BigDecimal', desc: '预警阈值', example: 100.0 }
      expose :time_range, documentation: { type: 'Integer', desc: '时间范围', example: 7 }
      expose :level, documentation: { type: 'String', desc: '预警级别', example: 'warning' }
      expose :enabled, documentation: { type: 'Boolean', desc: '是否启用', example: true }
      expose :description, documentation: { type: 'String', desc: '规则描述', example: '当新建Issue数量超过100时触发预警' }
      expose :created_at, documentation: { type: 'String', desc: '创建时间', example: '2024-01-15T10:30:00Z' }
      expose :updated_at, documentation: { type: 'String', desc: '更新时间', example: '2024-01-15T10:30:00Z' }
    end

    class DashboardAlertRuleListResponse < Grape::Entity
      expose :items, using: DashboardAlertRuleItem, documentation: { type: 'Array', desc: '规则列表', is_array: true }
      expose :totalCount, documentation: { type: 'Integer', desc: '总记录数', example: 100 }
      expose :currentPage, documentation: { type: 'Integer', desc: '当前页码', example: 1 }
      expose :perPage, documentation: { type: 'Integer', desc: '每页数量', example: 10 }
      expose :totalPages, documentation: { type: 'Integer', desc: '总页数', example: 10 }
    end

  end
end
