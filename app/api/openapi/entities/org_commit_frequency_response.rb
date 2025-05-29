# frozen_string_literal: true
# frozen_string_literal: true

module Openapi
  module Entities
    class OrgCommitFrequencyMetricDetail < Grape::Entity
      expose :org_commit_frequency,
             documentation: {
               type: 'Float',
               desc: '组织级提交频率（次/周）',
               example: 6.3720,
               format: 'float<0.0000-100.0000>',
               minimum: 0.0
             }

      expose :org_commit_frequency_bot,
             documentation: {
               type: 'Float',
               desc: '组织级机器人提交频率',
               example: 0.3891,
               format: 'float<0.0000-100.0000>'
             }

      expose :org_commit_frequency_without_bot,
             documentation: {
               type: 'Float',
               desc: '组织级人工提交频率',
               example: 5.9829,
               format: 'float<0.0000-100.0000>'
             }

      expose :org_commit_frequency_list,
             documentation: {
               type: 'Array[Float]',
               desc: '历史周频率序列',
               example: [6.1, 5.8, 6.5],
               is_array: true
             }
    end

    class OrgCommitFrequencyItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'metric_type', example: 'community_portrait' }
      expose :metric_name, documentation: { type: 'String', desc: 'metric_name', example: 'org_count' }
      expose :metric_detail, using: Entities::OrgCommitFrequencyMetricDetail,
                             documentation: { type: 'OrgCommitFrequencyMetricDetail', desc: 'metric_detail' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'version_number', example: nil } # 新增字段
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on',
                              example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class OrgCommitFrequencyResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: '当前页', example: 1 }
      expose :items, using: Entities::OrgCommitFrequencyItem,
                     documentation: { type: 'Entities::OrgCommitFrequencyItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
# module Openapi
#   module Entities
#     class OrgCommitFrequencyItem < Grape::Entity
#       expose :commit_frequency, documentation: { type: 'float', desc: 'commit_frequency', example: 0.5 }
#       expose :commit_frequency_bot, documentation: { type: 'float', desc: 'commit_frequency_bot', example: 0.3 }
#       expose :commit_frequency_without_bot, documentation: { type: 'float', desc: 'commit_frequency_without_bot', example: 0.2 }
#     end

#     class OrgCommitFrequencyResponse < Grape::Entity
#       expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
#       expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
#       expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
#       expose :items, using: Entities::OrgCommitFrequencyItem, documentation: { type: 'Entities::OrgCommitFrequencyItem', desc: 'response',
#                                                                             param_type: 'body', is_array: true }
#     end
#   end
# end
