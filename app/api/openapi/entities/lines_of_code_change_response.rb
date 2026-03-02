# frozen_string_literal: true

module Openapi
  module Entities

    class LinesOfCodeChangeItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on', example: '2025-05-14T07:28:30.512875+00:00' }



      expose :lines_added,
             documentation: {
               type: 'Integer',
               desc: 'Lines of Code Added / 新增代码行数',
               example: 5000,
               minimum: 0,
               nullable: true
             }
      expose :lines_removed,
             documentation: {
               type: 'Integer',
               desc: 'Lines of Code Removed / 删除代码行数',
               example: 1200,
               minimum: 0,
               nullable: true
             }
    end

    class LinesOfCodeChangeResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数' }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数' }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页' }
      expose :items, using: Entities::LinesOfCodeChangeItem,
             documentation: { type: 'LinesOfCodeChangeItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
