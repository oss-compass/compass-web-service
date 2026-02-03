# frozen_string_literal: true

module Openapi
  module Entities
    class IssueOpenTimeMetricDetail < Grape::Entity
      expose :issue_open_time_avg,
             documentation: {
               type: 'Float',
               desc: 'Average Issue Processing Time (Days) / Issue处理时长均值（单位：天）',
               example: 5.5,
               format: 'float',
               minimum: 0.0,
               nullable: true
             }

      expose :issue_open_time_mid,
             documentation: {
               type: 'Float',
               desc: 'Median Issue Processing Time (Days) / Issue处理时长中位数（单位：天）',
               example: 2.0,
               format: 'float',
               minimum: 0.0,
               nullable: true
             }
    end

    class IssueOpenTimeItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'metric_type', example: 'community_portrait' }
      expose :metric_name, documentation: { type: 'String', desc: 'metric_name', example: 'issue_open_time' }
      expose :metric_detail, using: Entities::IssueOpenTimeMetricDetail,
             documentation: { type: 'IssueOpenTimeMetricDetail', desc: 'metric_detail' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'version_number', example: nil }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on', example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class IssueOpenTimeResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::IssueOpenTimeItem,
             documentation: { type: 'Entities::IssueOpenTimeItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

