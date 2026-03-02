# frozen_string_literal: true

module Openapi
  module Entities
    class IndividualNonCodeContributionRatioItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :individual_non_code_contribution_ratio,
             documentation: {
               type: 'Float',
               desc: '个人非代码贡献量占非代码总贡献量比例 / Individual non-code contribution ratio',
               example: 0.45,
               minimum: 0.0,
               maximum: 1.0,
               nullable: true
             }
      expose :total_non_code_contribution,
             documentation: { type: 'Integer', desc: '非代码总贡献量 / Total non-code contribution', example: 250, nullable: true }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on', example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class IndividualNonCodeContributionRatioResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数' }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数' }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页' }
      expose :items, using: Entities::IndividualNonCodeContributionRatioItem,
             documentation: { type: 'IndividualNonCodeContributionRatioItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
