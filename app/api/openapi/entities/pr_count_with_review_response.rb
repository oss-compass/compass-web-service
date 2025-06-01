# frozen_string_literal: true
# frozen_string_literal: true

module Openapi
  module Entities
    class PrCountWithReviewMetricDetail < Grape::Entity
      expose :pr_count_with_review,
             documentation: {
               type: 'Integer',
               desc: '经过代码审查的PR总数',
               example: 15,
               minimum: 0,
               required: true
             }
    end

    class PrCountWithReviewItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'metric_type', example: 'community_portrait' }
      expose :metric_name, documentation: { type: 'String', desc: 'metric_name', example: 'pr_count_with_review' }
      expose :metric_detail, using: Entities::PrCountWithReviewMetricDetail,
                             documentation: { type: 'PrCountWithReviewMetricDetail', desc: 'metric_detail' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'version_number', example: nil } # 新增字段
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on',
                              example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class PrCountWithReviewResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: '当前页', example: 1 }
      expose :items, using: Entities::PrCountWithReviewItem,
                     documentation: { type: 'Entities::PrCountWithReviewItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
