# frozen_string_literal: true

module Openapi
  module Entities
    class EcologyMaintainerDocItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'e820aba0c5f29c1aac691cf75426bb4c87480b98' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :type, documentation: { type: 'NilClass', desc: 'type', example: nil }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Development Document Quality' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-04-01T00:00:00+00:00' }

      expose :ecology_maintainer_doc,
             documentation: {
               type: 'Integer',
               desc: 'Maintainer doc score / Committers文件分数',
               example: 0
             }

      expose :ecology_maintainer_doc_detail,
             documentation: {
               type: 'String',
               desc: 'Maintainer doc detail (nullable) / Committers文件详情（可为空）',
               example: nil,
               nullable: true
             }

      expose :committers_file_exists,
             documentation: {
               type: 'Boolean',
               desc: 'Whether committers file exists (OWNERS/MAINTAINERS) / 是否存在OWNERS/MAINTAINERS文件',
               example: false
             }

      expose :ecology_maintainer_doc_raw,
             documentation: {
               type: 'String',
               desc: 'Raw maintainer doc check result (JSON string) / Committers文件检查原始结果（JSON字符串）',
               example: '[]'
             }
    end

    class EcologyMaintainerDocResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::EcologyMaintainerDocItem,
             documentation: { type: 'Entities::EcologyMaintainerDocItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

