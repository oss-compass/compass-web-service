# frozen_string_literal: true

module Openapi
  module Entities
    class ComplianceCopyrightStatementItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: '56724d17217c589d87457b918f1ab1a916d114cc' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Legal Compliance' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-05-01T00:00:00+00:00' }

      expose :compliance_copyright_statement,
             documentation: {
               type: 'Integer',
               desc: 'License header & copyright statement compliance score / 许可头与版权声明分数',
               example: 0
             }

      expose :compliance_copyright_statement_detail,
             documentation: {
               type: 'String',
               desc: 'License header & copyright statement detail (JSON string) / 许可头与版权声明详情（JSON字符串）',
               example: "{'include_copyrights':[],'not_included_copyrights':['path/to/file'],'oat_detail':[]}"
             }
    end

    class ComplianceCopyrightStatementResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::ComplianceCopyrightStatementItem,
             documentation: { type: 'Entities::ComplianceCopyrightStatementItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

