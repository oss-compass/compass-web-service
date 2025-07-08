# frozen_string_literal: true
# frozen_string_literal: true

module Openapi
  module Entities
    class PrIssueLinkedRatioMetricDetail < Grape::Entity
      expose :pr_issue_linked_ratio,
             documentation: {
               type: 'Float',
               desc: 'Ratio of PRs Linked to Issues (Number of PRs with Issue Links/Total PRs) / 关联Issue的PR比例（关联Issue的PR数/总PR数）',
               example: 0.6500,
               format: 'float<0.0000-1.0000>',
               minimum: 0.0,
               maximum: 1.0,
               nullable: true,
               required: true
             }
    end

    class PrIssueLinkedRatioItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'metric_type', example: 'community_portrait' }
      expose :metric_name, documentation: { type: 'String', desc: 'metric_name', example: 'pr_issue_linked_ratio' }
      expose :metric_detail, using: Entities::PrIssueLinkedRatioMetricDetail,
             documentation: { type: 'PrIssueLinkedRatioMetricDetail', desc: 'metric_detail' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'version_number', example: nil } # 新增字段
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on',
                              example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class PrIssueLinkedRatioResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::PrIssueLinkedRatioItem,
             documentation: { type: 'Entities::PrIssueLinkedRatioItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
