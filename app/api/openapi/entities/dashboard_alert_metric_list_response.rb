# frozen_string_literal: true
module Openapi
  module Entities

    class DashboardAlertMetricItem < Grape::Entity
      expose :key, documentation: { type: 'String', desc: '指标key', example: 'new_issue_count' }
      expose :name, documentation: { type: 'String', desc: '指标名称', example: '新建Issue数量' }
    end

    class DashboardAlertMetricListResponse < Grape::Entity
      expose :metrics, using: DashboardAlertMetricItem, documentation: { type: 'Array', desc: '指标列表', is_array: true }
    end

  end
end
