# frozen_string_literal: true
# frozen_string_literal: true

module Openapi
  module Entities
    class PrTimeToFirstResponseMetricDetail < Grape::Entity
      expose :pr_time_to_first_response_avg,
             documentation: {
               type: 'Float',
               desc: 'PR首次响应时间平均值（单位：小时）',
               example: 8.4567,
               format: 'float<0.0000-999.9999>',
               minimum: 0.0,
               nullable: true,
               required: true
             }

      expose :pr_time_to_first_response_mid,
             documentation: {
               type: 'Float',
               desc: 'PR首次响应时间中位数',
               example: 4.2300,
               format: 'float<0.0000-999.9999>',
               minimum: 0.0,
               nullable: true,
               required: true
             }
    end

    class PrTimeToFirstResponseItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'metric_type', example: 'community_portrait' }
      expose :metric_name, documentation: { type: 'String', desc: 'metric_name', example: 'pr_open_time' }
      expose :metric_detail, using: Entities::PrTimeToFirstResponseMetricDetail,
                             documentation: { type: 'PrTimeToFirstResponseMetricDetail', desc: 'metric_detail' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'version_number', example: nil } # 新增字段
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on',
                              example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class PrTimeToFirstResponseResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: '当前页', example: 1 }
      expose :items, using: Entities::PrTimeToFirstResponseItem,
                     documentation: { type: 'Entities::PrTimeToFirstResponseItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
# module Openapi
#   module Entities
#     class PrTimeToFirstResponseItem < Grape::Entity
#       expose :commit_frequency, documentation: { type: 'float', desc: 'commit_frequency', example: 0.5 }
#       expose :commit_frequency_bot, documentation: { type: 'float', desc: 'commit_frequency_bot', example: 0.3 }
#       expose :commit_frequency_without_bot, documentation: { type: 'float', desc: 'commit_frequency_without_bot', example: 0.2 }
#     end

#     class PrTimeToFirstResponseResponse < Grape::Entity
#       expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
#       expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
#       expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
#       expose :items, using: Entities::PrTimeToFirstResponseItem, documentation: { type: 'Entities::PrTimeToFirstResponseItem', desc: 'response',
#                                                                             param_type: 'body', is_array: true }
#     end
#   end
# end
