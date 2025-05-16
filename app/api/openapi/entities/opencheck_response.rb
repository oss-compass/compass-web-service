# frozen_string_literal: true
module Openapi
  module Entities

    class OpencheckItem < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }

    end

    class OpencheckResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::OpencheckItem, documentation: { type: 'Entities::OpencheckItem', desc: 'response',
                                                                 param_type: 'body', is_array: true }

    end

  end
end
