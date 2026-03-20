# frozen_string_literal: true

module Openapi
  module Entities
    class ComplianceSnippetReferenceItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: '58cd018b007ee61cebd92e9147fdd33d7bab3e93' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :type, documentation: { type: 'NilClass', desc: 'type', example: nil }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Code Review Quality' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-05-01T00:00:00+00:00' }

      expose :compliance_snippet_reference,
             documentation: {
               type: 'Integer',
               desc: 'Snippet reference compliance score / 片段引用合规分数',
               example: -1
             }

      expose :compliance_snippet_reference_detail,
             documentation: {
               type: 'String',
               desc: 'Snippet reference detail (JSON string) / 片段引用详情（JSON字符串）',
               example: "{\"unavailable\":true}"
             }

      expose :violation_count,
             documentation: {
               type: 'Integer',
               desc: 'Violation snippet count / 违规片段数',
               example: nil,
               nullable: true
             }
    end

    class ComplianceSnippetReferenceResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::ComplianceSnippetReferenceItem,
             documentation: { type: 'Entities::ComplianceSnippetReferenceItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

