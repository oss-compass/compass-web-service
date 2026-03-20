# frozen_string_literal: true

module Openapi
  module Entities
    class LifecycleStatementItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: '0d7baba265d123efc8f9274a6a3793bebcf49f58' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :type, documentation: { type: 'NilClass', desc: 'type', example: nil }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Maintenance Management' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-02-01T00:00:00+00:00' }

      expose :lifecycle_statement,
             documentation: {
               type: 'Integer',
               desc: 'Lifecycle statement score / 生命周期申明分数',
               example: 0
             }

      expose :lifecycle_statement_exists,
             documentation: {
               type: 'Boolean',
               desc: 'Whether lifecycle statement exists / 是否存在生命周期申明',
               example: false
             }

      expose :lifecycle_statement_detail,
             documentation: {
               type: 'String',
               desc: 'Lifecycle statement detail (JSON string) / 生命周期申明详情（JSON字符串）',
               example: '{}'
             }
    end

    class LifecycleStatementResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::LifecycleStatementItem,
             documentation: { type: 'Entities::LifecycleStatementItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

