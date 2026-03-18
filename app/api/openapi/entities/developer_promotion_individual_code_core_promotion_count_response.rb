# frozen_string_literal: true

module Openapi
  module Entities
    class DeveloperPromotionIndividualCodeCorePromotionCountItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :individual_code_core_promotion_count,
             documentation: {
               type: 'Integer',
               desc: 'Individual code core promotion count / 个人代码核心晋升数量',
               example: 0,
               minimum: 0,
               nullable: true
             }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    class DeveloperPromotionIndividualCodeCorePromotionCountResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数' }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数' }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页' }
      expose :items, using: Entities::DeveloperPromotionIndividualCodeCorePromotionCountItem,
             documentation: { type: 'DeveloperPromotionIndividualCodeCorePromotionCountItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
