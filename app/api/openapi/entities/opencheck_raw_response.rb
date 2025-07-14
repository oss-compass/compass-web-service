# frozen_string_literal: true
module Openapi
  module Entities

    class OpencheckRawItem < Grape::Entity
      expose :project_url, documentation: { type: 'String', desc: 'repo url', example: "" }
      expose :label, documentation: { type: 'String', desc: 'repo url', example: "" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :command, documentation: { type: 'String', desc: 'command', example: '' }
      expose :command_result, documentation: { type: 'body', desc: 'command', example: '' }
      expose :id, documentation: { type: 'String', desc: 'id', example: '' }
    end

    class OpencheckRawResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::OpencheckRawItem, documentation: { type: 'Entities::OpencheckRawItem', desc: 'response',
                                                                 param_type: 'body', is_array: true }

    end

  end
end
