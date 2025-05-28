# frozen_string_literal: true
# frozen_string_literal: true

module Openapi
  module Entities
    class PrCountMetricDetail < Grape::Entity
      expose :total_create_close_pr_count,
             documentation: {
               type: 'Integer',
               desc: '已关闭PR总数（包含用户创建并关闭的PR）',
               example: 23,
               minimum: 0,
               required: true
             }
    end

    class PrCountItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'metric_type', example: 'community_portrait' }
      expose :metric_name,
             documentation: { type: 'String', desc: 'metric_name', example: 'total_create_close_pr_count' }
      expose :metric_detail, using: Entities::PrCountMetricDetail,
                             documentation: { type: 'PrCountMetricDetail', desc: 'metric_detail' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'version_number', example: nil } # 新增字段
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on',
                              example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class PrCountResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: '当前页', example: 1 }
      expose :items, using: Entities::PrCountItem,
                     documentation: { type: 'Entities::PrCountItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
