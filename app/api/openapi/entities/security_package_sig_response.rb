# frozen_string_literal: true

module Openapi
  module Entities
    class SecurityPackageSigItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'a146daa47aa4edcafedb4728073ceded85cd30a4' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :type, documentation: { type: 'NilClass', desc: 'type', example: nil }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Release Quality' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-03-01T00:00:00+00:00' }

      expose :security_package_sig,
             documentation: {
               type: 'Integer',
               desc: 'Package signature validity score / 软件包签名分数',
               example: -1
             }
    end

    class SecurityPackageSigResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::SecurityPackageSigItem,
             documentation: { type: 'Entities::SecurityPackageSigItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

