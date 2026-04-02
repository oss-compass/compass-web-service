# frozen_string_literal: true

module Openapi
  module Entities
    class V3MetricModelGraphDataResponse < Grape::Entity
      expose :code, documentation: { type: 'Integer', desc: 'Status code / 状态码', example: 201 }
      expose :message, documentation: { type: 'String', desc: 'Message / 消息', example: 'Success' }
      expose :data, using: Entities::V3ModelOverviewItem,
             documentation: { type: 'Entities::V3ModelOverviewItem', desc: 'Overview items with score / 含 score 的概览项',
                              param_type: 'body', is_array: true }
    end
  end
end
