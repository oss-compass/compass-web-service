# frozen_string_literal: true
module Openapi
  module Entities

    class DowncountItem < Grape::Entity
      expose :down_count_npm, documentation: { type: 'int', desc: 'down_count_npm', example: 0 }
      expose :down_count_ohpm, documentation: { type: 'int', desc: 'down_count_ohpm', example: 23 }
      expose :day_enter, documentation: { type: 'String', desc: 'day_enter' }
    end

    class OpencheckDowncountResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'count / 总数', example: 100 }
      expose :items, using: Entities::DowncountItem, documentation: { type: 'Entities::DowncountItem', desc: 'response',
                                                                      param_type: 'body', is_array: true }
    end
  end
end
