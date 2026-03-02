# frozen_string_literal: true
# Shared structure for development_governance metrics (organizational & personal).
# Each metric defines its own MetricDetail class exposing the specific value(s).

module Openapi
  module Entities
    class GovernanceMetricItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :metric_type, documentation: { type: 'String', desc: 'metric_type' }
      expose :metric_name, documentation: { type: 'String', desc: 'metric_name' }
      expose :metric_detail, documentation: { type: 'Object', desc: 'metric_detail' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'version_number', example: nil }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    class GovernanceMetricResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数' }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数' }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页' }
      expose :items, using: Entities::GovernanceMetricItem,
             documentation: { type: 'GovernanceMetricItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
