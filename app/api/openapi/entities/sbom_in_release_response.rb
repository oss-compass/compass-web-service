# frozen_string_literal: true

module Openapi
  module Entities
    class SbomInReleaseItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'a146daa47aa4edcafedb4728073ceded85cd30a4' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :type, documentation: { type: 'NilClass', desc: 'type', example: nil }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Release Quality' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-03-01T00:00:00+00:00' }

      expose :sbom_in_release,
             documentation: {
               type: 'Boolean',
               desc: 'Whether SBOM file exists in release assets / 发布软件版本中是否包含SBOM文件',
               example: nil,
               nullable: true
             }

      expose :detail,
             documentation: {
               type: 'String',
               desc: 'Detail message / 详情信息',
               example: 'no release-checker data'
             }
    end

    class SbomInReleaseResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::SbomInReleaseItem,
             documentation: { type: 'Entities::SbomInReleaseItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

