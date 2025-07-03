# frozen_string_literal: true
# frozen_string_literal: true

module Openapi
  module Entities
    class ClosePrCountMetricDetail < Grape::Entity
      expose :close_pr_count,
             documentation: {
               type: 'Integer',
               desc: '已关闭PR总数',
               example: 15,
               minimum: 0,
               required: true
             }
    end

    class ClosePrCountItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'metric_type', example: 'community_portrait' }
      expose :metric_name, documentation: { type: 'String', desc: 'metric_name', example: 'code_review_count' }
      expose :metric_detail, using: Entities::ClosePrCountMetricDetail,
                             documentation: { type: 'ClosePrCountMetricDetail', desc: 'metric_detail' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'version_number', example: nil } # 新增字段
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on',
                              example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class ClosePrCountResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: '当前页', example: 1 }
      expose :items, using: Entities::ClosePrCountItem,
                     documentation: { type: 'Entities::ClosePrCountItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
# module Openapi
#   module Entities
#     class ClosePrCountItem < Grape::Entity
#       expose :commit_frequency, documentation: { type: 'float', desc: 'commit_frequency', example: 0.5 }
#       expose :commit_frequency_bot, documentation: { type: 'float', desc: 'commit_frequency_bot', example: 0.3 }
#       expose :commit_frequency_without_bot, documentation: { type: 'float', desc: 'commit_frequency_without_bot', example: 0.2 }
#     end

#     class ClosePrCountResponse < Grape::Entity
#       expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
#       expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
#       expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
#       expose :items, using: Entities::ClosePrCountItem, documentation: { type: 'Entities::ClosePrCountItem', desc: 'response',
#                                                                             param_type: 'body', is_array: true }
#     end
#   end
# end
