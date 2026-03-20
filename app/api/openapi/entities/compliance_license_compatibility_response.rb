# frozen_string_literal: true

module Openapi
  module Entities
    class ComplianceLicenseCompatibilityItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: '56724d17217c589d87457b918f1ab1a916d114cc' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Legal Compliance' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-05-01T00:00:00+00:00' }

      expose :compliance_license_compatibility,
             documentation: {
               type: 'Integer',
               desc: 'License compatibility compliance score / 许可证兼容性分数',
               example: 10
             }

      expose :compliance_license_compatibility_detail,
             documentation: {
               type: 'String',
               desc: 'License compatibility detail (JSON string) / 许可证兼容性详情（JSON字符串）',
               example: "{'conflicts':[],'count':0}"
             }

      expose :license_compatibility_conflicts,
             documentation: {
               type: 'String',
               is_array: true,
               desc: 'Detected license compatibility conflicts / 许可证兼容性冲突列表',
               example: ''
             }
    end

    class ComplianceLicenseCompatibilityResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::ComplianceLicenseCompatibilityItem,
             documentation: { type: 'Entities::ComplianceLicenseCompatibilityItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

