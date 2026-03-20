# frozen_string_literal: true

module Openapi
  module Entities
    class DependencyReachableItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: '58cd018b007ee61cebd92e9147fdd33d7bab3e93' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :type, documentation: { type: 'NilClass', desc: 'type', example: nil }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Code Review Quality' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-05-01T00:00:00+00:00' }

      expose :dependency_reachable_ok,
             documentation: {
               type: 'Boolean',
               desc: 'Whether all dependencies are reachable / 依赖是否全部可获得',
               example: nil,
               nullable: true
             }

      expose :dependency_unreachable_list,
             documentation: {
               type: 'String',
               is_array: true,
               desc: 'Unreachable dependency list / 不可达依赖列表',
               example: []
             }

      expose :detail,
             documentation: {
               type: 'String',
               desc: 'Detail message / 详情信息',
               example: 'no dependency-reachable-checker data'
             }
    end

    class DependencyReachableResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::DependencyReachableItem,
             documentation: { type: 'Entities::DependencyReachableItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

