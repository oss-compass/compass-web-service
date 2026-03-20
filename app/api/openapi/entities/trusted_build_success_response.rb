# frozen_string_literal: true

module Openapi
  module Entities
    class TrustedBuildSuccessItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'ec008098aad1d09fce57644cd1ed72388e1c7840' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :type, documentation: { type: 'NilClass', desc: 'type', example: nil }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Trusted Build' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-05-01T00:00:00+00:00' }

      expose :ecology_build_success_rate,
             documentation: {
               type: 'Float',
               desc: 'Build success rate / 构建成功率',
               example: nil,
               nullable: true
             }

      expose :build_checker_present,
             documentation: {
               type: 'Boolean',
               desc: 'Whether build checker data is present / 是否存在构建检查数据',
               example: false
             }
    end

    class TrustedBuildSuccessResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::TrustedBuildSuccessItem,
             documentation: { type: 'Entities::TrustedBuildSuccessItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

