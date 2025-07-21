# frozen_string_literal: true
module Openapi
  module Entities

    class DependentItem < Grape::Entity
      expose :dependent_npm, documentation: { type: 'int', desc: 'dependent_npm', example: 23 }
      expose :dependent_ohpm, documentation: { type: 'int', desc: 'dependent_ohpm', example: 23 }
      expose :bedependent_ohpm, documentation: { type: 'int', desc: 'bedependent_ohpm', example: 23 }
    end

    class OpencheckDependentResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'count / 总数', example: 100 }
      expose :items, using: Entities::DependentItem, documentation: { type: 'Entities::DependentItem', desc: 'response',
                                                                      param_type: 'body', is_array: true }
    end
  end
end
