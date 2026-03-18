# frozen_string_literal: true

module Openapi
  module Entities
    class ParticipationTierOrgCodeCoreContributorsItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: '8b17b66a30c800d9b917bdf688331c194f2b5cdb' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/Unleash/unleash' }
      expose :org_code_core_contributors,
             documentation: {
               type: 'Integer',
               desc: 'Org code core contributors (incl. managers) / 组织代码核心开发者（含管理者）数量',
               example: 2,
               minimum: 0,
               nullable: true
             }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-01-01T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on', example: '2026-03-16T01:11:05.189538+00:00' }
    end

    class ParticipationTierOrgCodeCoreContributorsResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数' }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数' }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页' }
      expose :items, using: Entities::ParticipationTierOrgCodeCoreContributorsItem,
             documentation: { type: 'ParticipationTierOrgCodeCoreContributorsItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
