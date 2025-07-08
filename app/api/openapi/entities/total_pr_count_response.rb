# frozen_string_literal: true
# frozen_string_literal: true

module Openapi
  module Entities
    class TotalPrCountMetricDetail < Grape::Entity
      expose :total_pr_count,
             documentation: {
               type: 'Integer',
               desc: 'Total Pull Requests (Including All States: open/closed/merged) / 拉取请求总量（包含所有状态：open/closed/merged）',
               example: 100,
               minimum: 0,
               required: true
             }
    end

    class TotalPrCountItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'metric_type', example: 'community_portrait' }
      expose :metric_name,
             documentation: { type: 'String', desc: 'metric_name', example: 'total_pr_count' }
      expose :metric_detail, using: Entities::TotalPrCountMetricDetail,
             documentation: { type: 'TotalPrCountMetricDetail', desc: 'metric_detail' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'version_number', example: nil } # 新增字段
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on',
                              example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class TotalPrCountResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::TotalPrCountItem,
             documentation: { type: 'Entities::TotalPrCountItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
