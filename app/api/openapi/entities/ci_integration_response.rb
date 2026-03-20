# frozen_string_literal: true

module Openapi
  module Entities
    class CiIntegrationItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'ec008098aad1d09fce57644cd1ed72388e1c7840' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :type, documentation: { type: 'NilClass', desc: 'type', example: nil }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Trusted Build' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-05-01T00:00:00+00:00' }

      expose :ecology_ci,
             documentation: {
               type: 'Integer',
               desc: 'CI integration score / CI集成分数',
               example: 0
             }

      expose :ci_integration,
             documentation: {
               type: 'Boolean',
               desc: 'Whether CI is configured/enabled / 是否配置并启用了CI',
               example: false
             }
    end

    class CiIntegrationResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::CiIntegrationItem,
             documentation: { type: 'Entities::CiIntegrationItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

