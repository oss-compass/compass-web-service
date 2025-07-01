# frozen_string_literal: true
module Openapi
  module Entities

    class OpencheckItem < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count/总数', example: 100 }

    end

    class OpencheckResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count/总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages/总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page/当前页', example: 1 }
      expose :items, using: Entities::OpencheckItem, documentation: { type: 'Entities::OpencheckItem', desc: 'response',
                                                                      param_type: 'body', is_array: true }

    end

  end
end
