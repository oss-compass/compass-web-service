# frozen_string_literal: true
# frozen_string_literal: true

module Openapi
  module Entities
    class ClosePrCountMetricDetail < Grape::Entity
      expose :close_pr_count,
             documentation: {
               type: 'Integer',
               desc: 'Total Closed PRs / 已关闭PR总数',
               example: 15,
               minimum: 0,
               required: true
             }
    end

    class ClosePrCountItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'Unique Identifier / 唯一标识符', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'Analysis Level / 分析层级', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'Repository URL / 仓库地址', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'Metric Type / 指标类型', example: 'community_portrait' }
      expose :metric_name, documentation: { type: 'String', desc: 'Metric Name / 指标名称', example: 'code_review_count' }
      expose :metric_detail, using: Entities::ClosePrCountMetricDetail,
             documentation: { type: 'ClosePrCountMetricDetail', desc: 'Metric Details / 指标详情' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'Version Number / 版本号', example: nil } # 新增字段
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'Metric Calculation Time / 指标计算时间', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'Metadata Update Time / 元数据更新时间',
                              example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class ClosePrCountResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Records / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::ClosePrCountItem,
             documentation: { type: 'Entities::ClosePrCountItem', desc: 'Response Items / 响应项', param_type: 'body', is_array: true }
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
