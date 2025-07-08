# frozen_string_literal: true
# frozen_string_literal: true

module Openapi
  module Entities
    class LinesAddOfCodeFrequencyMetricDetail < Grape::Entity
      expose :lines_add_of_code_frequency,
             documentation: {
               type: 'Float',
               desc: 'Code Lines Addition Frequency (times/week) / 新增代码行频率（单位：次/周）',
               example: 12.8,
               minimum: 0.0,
               format: 'float',
               nullable: true,
               required: true
             }
    end

    class LinesAddOfCodeFrequencyItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'Unique ID / 唯一标识', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'Repository Level / 仓库层级', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'Repository Label / 仓库标签', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'Metric Type / 指标类型', example: 'community_portrait' }
      expose :metric_name,
             documentation: { type: 'String', desc: 'Metric Name / 指标名称', example: 'lines_add_of_code_frequency' }
      expose :metric_detail, using: Entities::LinesAddOfCodeFrequencyMetricDetail,
             documentation: { type: 'LinesAddOfCodeFrequencyMetricDetail', desc: 'Metric Details / 指标详情' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'Version Number / 版本号', example: nil } # 新增字段
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'Creation Date / 创建日期', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on',
                              example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class LinesAddOfCodeFrequencyResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::LinesAddOfCodeFrequencyItem,
             documentation: { type: 'Entities::LinesAddOfCodeFrequencyItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
# module Openapi
#   module Entities
#     class LinesAddOfCodeFrequencyItem < Grape::Entity
#       expose :commit_frequency, documentation: { type: 'float', desc: 'commit_frequency', example: 0.5 }
#       expose :commit_frequency_bot, documentation: { type: 'float', desc: 'commit_frequency_bot', example: 0.3 }
#       expose :commit_frequency_without_bot, documentation: { type: 'float', desc: 'commit_frequency_without_bot', example: 0.2 }
#     end

#     class LinesAddOfCodeFrequencyResponse < Grape::Entity
#       expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
#       expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
#       expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
#       expose :items, using: Entities::LinesAddOfCodeFrequencyItem, documentation: { type: 'Entities::LinesAddOfCodeFrequencyItem', desc: 'response',
#                                                                             param_type: 'body', is_array: true }
#     end
#   end
# end
