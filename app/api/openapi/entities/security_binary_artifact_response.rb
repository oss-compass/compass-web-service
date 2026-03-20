# frozen_string_literal: true

module Openapi
  module Entities
    class SecurityBinaryArtifactItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'a146daa47aa4edcafedb4728073ceded85cd30a4' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :type, documentation: { type: 'NilClass', desc: 'type', example: nil }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Release Quality' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-03-01T00:00:00+00:00' }

      expose :security_binary_artifact,
             documentation: {
               type: 'Integer',
               desc: 'Binary artifact compliance score / 二进制制品包含分数',
               example: 10
             }

      expose :security_binary_artifact_detail,
             documentation: {
               type: 'String',
               desc: 'Binary artifact detail (JSON string) / 二进制制品详情（JSON字符串）',
               example: '[]'
             }

      expose :binary_violation_files,
             documentation: {
               type: 'String',
               is_array: true,
               desc: 'Violation binary files list / 违规二进制文件列表',
               example: []
             }

      expose :binary_archive_list,
             documentation: {
               type: 'String',
               is_array: true,
               desc: 'Binary archive list / 二进制归档列表',
               example: []
             }

      expose :security_binary_artifact_raw,
             documentation: {
               type: 'String',
               desc: 'Raw binary artifact scan result (JSON string) / 二进制制品扫描原始结果（JSON字符串）',
               example: '[]'
             }
    end

    class SecurityBinaryArtifactResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::SecurityBinaryArtifactItem,
             documentation: { type: 'Entities::SecurityBinaryArtifactItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

