# frozen_string_literal: true

module Openapi
  module Entities
    class ComplianceCopyrightAntiTamperItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: '56724d17217c589d87457b918f1ab1a916d114cc' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :type, documentation: { type: 'NilClass', desc: 'type', example: nil }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Legal Compliance' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-05-01T00:00:00+00:00' }

      expose :compliance_copyright_statement_anti_tamper,
             documentation: {
               type: 'Integer',
               desc: 'Anti-tamper compliance score / 许可证与版权声明防篡改分数',
               example: -1
             }

      expose :compliance_copyright_statement_anti_tamper_detail,
             documentation: {
               type: 'String',
               desc: 'Anti-tamper detail (JSON string) / 防篡改详情（JSON字符串）',
               example: "{\"unavailable\":true}"
             }
    end

    class ComplianceCopyrightAntiTamperResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::ComplianceCopyrightAntiTamperItem,
             documentation: { type: 'Entities::ComplianceCopyrightAntiTamperItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

