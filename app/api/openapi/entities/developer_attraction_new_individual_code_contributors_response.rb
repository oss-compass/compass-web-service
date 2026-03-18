# frozen_string_literal: true

module Openapi
  module Entities
    class DeveloperAttractionNewIndividualCodeContributorsItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: '1a6b2c32a0a4b62d15960264727f09303c8b6f23' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/Unleash/unleash' }
      expose :new_individual_code_contributors,
             documentation: {
               type: 'Integer',
               desc: 'New individual code contributors / 新增个人代码开发者数量',
               example: 2,
               minimum: 0,
               nullable: true
             }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-01-01T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on', example: '2026-03-16T01:11:00.970378+00:00' }
    end

    class DeveloperAttractionNewIndividualCodeContributorsResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数' }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数' }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页' }
      expose :items, using: Entities::DeveloperAttractionNewIndividualCodeContributorsItem,
             documentation: { type: 'DeveloperAttractionNewIndividualCodeContributorsItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
