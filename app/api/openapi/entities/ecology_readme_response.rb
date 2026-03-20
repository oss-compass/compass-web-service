# frozen_string_literal: true

module Openapi
  module Entities
    class EcologyReadmeItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'e820aba0c5f29c1aac691cf75426bb4c87480b98' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :type, documentation: { type: 'NilClass', desc: 'type', example: nil }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Development Document Quality' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-04-01T00:00:00+00:00' }

      expose :ecology_readme,
             documentation: {
               type: 'Integer',
               desc: 'README quality score / README文档质量分数',
               example: 0
             }

      expose :ecology_readme_detail,
             documentation: {
               type: 'String',
               desc: 'README detail (JSON string) / README详情（JSON字符串）',
               example: "{\"score_0_10\":0,\"readme_file_count\":0}"
             }

      expose :readme_completeness_score,
             documentation: {
               type: 'Integer',
               desc: 'README completeness score / 文档完整度得分',
               example: 0
             }

      expose :ecology_readme_raw,
             documentation: {
               type: 'String',
               desc: 'Raw README check result (JSON string) / README检查原始结果（JSON字符串）',
               example: '[]'
             }
    end

    class EcologyReadmeResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::EcologyReadmeItem,
             documentation: { type: 'Entities::EcologyReadmeItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

