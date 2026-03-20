# frozen_string_literal: true

module Openapi
  module Entities
    class PatentRiskOinItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: '58cd018b007ee61cebd92e9147fdd33d7bab3e93' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :type, documentation: { type: 'NilClass', desc: 'type', example: nil }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Code Review Quality' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-05-01T00:00:00+00:00' }

      expose :patent_risk_level,
             documentation: {
               type: 'String',
               desc: 'Patent risk level / 专利风险等级',
               example: nil,
               nullable: true
             }

      expose :patent_risk_unavailable,
             documentation: {
               type: 'Boolean',
               desc: 'Whether patent risk data is unavailable / 是否无法获取专利风险数据',
               example: true
             }

      expose :patent_risk_detail,
             documentation: {
               type: 'String',
               desc: 'Patent risk detail (JSON string) / 专利风险详情（JSON字符串）',
               example: "{}"
             }
    end

    class PatentRiskOinResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::PatentRiskOinItem,
             documentation: { type: 'Entities::PatentRiskOinItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

