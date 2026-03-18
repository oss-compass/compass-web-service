# frozen_string_literal: true

module Openapi
  module Entities
    class CoreChurnOrgCodeCoreChurnItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :org_code_core_churn,
             documentation: {
               type: 'Float',
               desc: 'Org code core churn (ratio) / 组织代码核心开发者（含管理者）淡出率',
               example: 0.5,
               nullable: true
             }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    class CoreChurnOrgCodeCoreChurnResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数' }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数' }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页' }
      expose :items, using: Entities::CoreChurnOrgCodeCoreChurnItem,
             documentation: { type: 'CoreChurnOrgCodeCoreChurnItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
