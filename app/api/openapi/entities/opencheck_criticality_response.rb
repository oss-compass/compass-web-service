# frozen_string_literal: true
module Openapi
  module Entities

    class CriticalityItem < Grape::Entity
      expose :criticality_score, documentation: { type: 'float', desc: 'criticality_score', example: 0.32782 }
    end

    class OpencheckCriticalityResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'count / 总数', example: 100 }
      expose :items, using: Entities::CriticalityItem, documentation: { type: 'Entities::CriticalityItem', desc: 'response',
                                                                        param_type: 'body', is_array: true }
    end
  end
end
