# frozen_string_literal: true

module Openapi
  module Entities
    class IssueUnresponsiveRateMetricDetail < Grape::Entity
      expose :issue_unresponsive_rate,
             documentation: {
               type: 'Float',
               desc: 'Issue Unresponsive Rate (No response for > 1 cycle) / Issue超过一个周期未响应的占比',
               example: 0.12,
               format: 'float<0.0000-1.0000>',
               minimum: 0.0,
               maximum: 1.0,
               nullable: true
             }
    end

    class IssueUnresponsiveRateItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'metric_type', example: 'collaboration_efficiency' }
      expose :metric_name, documentation: { type: 'String', desc: 'metric_name', example: 'issue_unresponsive_rate' }
      expose :metric_detail, using: Entities::IssueUnresponsiveRateMetricDetail,
             documentation: { type: 'IssueUnresponsiveRateMetricDetail', desc: 'metric_detail' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'version_number', example: nil }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on', example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class IssueUnresponsiveRateResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::IssueUnresponsiveRateItem,
             documentation: { type: 'Entities::IssueUnresponsiveRateItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

