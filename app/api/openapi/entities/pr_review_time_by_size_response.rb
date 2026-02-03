# frozen_string_literal: true
# frozen_string_literal: true

module Openapi
  module Entities
    class PrReviewTimeBySizeMetricDetail < Grape::Entity
      expose :xs, documentation: { type: 'Float', desc: 'XS PR average review time (hours) / XS PR 平均审查时长（小时）', example: 2.1, nullable: true, required: true }
      expose :s, documentation: { type: 'Float', desc: 'S PR average review time (hours) / S PR 平均审查时长（小时）', example: 3.4, nullable: true, required: true }
      expose :m, documentation: { type: 'Float', desc: 'M PR average review time (hours) / M PR 平均审查时长（小时）', example: 5.7, nullable: true, required: true }
      expose :l, documentation: { type: 'Float', desc: 'L PR average review time (hours) / L PR 平均审查时长（小时）', example: 9.2, nullable: true, required: true }
      expose :xl, documentation: { type: 'Float', desc: 'XL PR average review time (hours) / XL PR 平均审查时长（小时）', example: 14.8, nullable: true, required: true }
    end

    class PrReviewTimeBySizeItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'metric_type', example: 'community_portrait' }
      expose :metric_name, documentation: { type: 'String', desc: 'metric_name', example: 'pr_review_time_by_size' }
      expose :metric_detail, using: Entities::PrReviewTimeBySizeMetricDetail,
             documentation: { type: 'PrReviewTimeBySizeMetricDetail', desc: 'metric_detail' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'version_number', example: nil }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on', example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class PrReviewTimeBySizeResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::PrReviewTimeBySizeItem,
             documentation: { type: 'Entities::PrReviewTimeBySizeItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
