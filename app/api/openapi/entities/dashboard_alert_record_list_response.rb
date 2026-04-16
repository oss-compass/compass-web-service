# frozen_string_literal: true
module Openapi
  module Entities

    class DashboardAlertRuleInfo < Grape::Entity
      expose :id, documentation: { type: 'Integer', desc: '规则ID', example: 1 }
      expose :metric_name, documentation: { type: 'String', desc: '监控指标名称', example: '新建Issue数量' }
      expose :level, documentation: { type: 'String', desc: '预警级别', example: 'warning' }
    end

    class DashboardAlertRecordItem < Grape::Entity
      expose :id, documentation: { type: 'Integer', desc: '记录ID', example: 1 }
      expose :dashboard_id, documentation: { type: 'Integer', desc: '看板ID', example: 1 }
      expose :dashboard_alert_rule_id, documentation: { type: 'Integer', desc: '规则ID', example: 1 }
      expose :triggered_at, documentation: { type: 'String', desc: '触发时间', example: '2024-01-15T10:30:00Z' }
      expose :metric_value, documentation: { type: 'BigDecimal', desc: '指标值', example: 150.0 }
      expose :threshold, documentation: { type: 'BigDecimal', desc: '阈值', example: 100.0 }
      expose :message, documentation: { type: 'String', desc: '预警消息', example: '新建Issue数量超过阈值' }
      expose :created_at, documentation: { type: 'String', desc: '创建时间', example: '2024-01-15T10:30:00Z' }
      expose :dashboard_alert_rule, using: DashboardAlertRuleInfo, documentation: { type: 'Object', desc: '关联的规则信息' }
    end

    class DashboardAlertRecordListResponse < Grape::Entity
      expose :items, using: DashboardAlertRecordItem, documentation: { type: 'Array', desc: '记录列表', is_array: true }
      expose :totalCount, documentation: { type: 'Integer', desc: '总记录数', example: 100 }
      expose :currentPage, documentation: { type: 'Integer', desc: '当前页码', example: 1 }
      expose :perPage, documentation: { type: 'Integer', desc: '每页数量', example: 10 }
      expose :totalPages, documentation: { type: 'Integer', desc: '总页数', example: 10 }
    end

  end
end
