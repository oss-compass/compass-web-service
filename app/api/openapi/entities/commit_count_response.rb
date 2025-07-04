# frozen_string_literal: true

module Openapi
  module Entities
    # 提交详情嵌套结构
    class CommitCountMetricDetail < Grape::Entity
      expose :commit_count, documentation: { type: 'Integer', desc: 'Total Commits / 总提交数', example: 82 }
      expose :commit_count_bot, documentation: { type: 'Integer', desc: 'Bot Commits / 机器人提交数', example: 5 }
      expose :commit_count_without_bot, documentation: { type: 'Integer', desc: 'Human Commits / 非机器人提交数', example: 77 }
    end

    # 单条提交记录
    class CommitCountItem < Grape::Entity
      expose :uuid, documentation: {
        type: 'String',
        desc: 'Unique Identifier / 唯一标识符',
        example: 'f4fa02df6ab101d652b92d4ef45380472f0374a8'
      }

      expose :level, documentation: {
        type: 'String',
        desc: 'Analysis Level / 分析层级',
        example: 'repo',
        values: %w[repo org] # 枚举约束
      }

      expose :label, documentation: {
        type: 'String',
        desc: 'Repository URL / 仓库地址',
        example: 'https://github.com/oss-compass/compass-web-service'
      }
      expose :metric_type, documentation: { type: 'String', desc: 'Metric Type / 指标类型', example: 'community_portrait' }
      expose :metric_name, documentation: { type: 'String', desc: 'Metric Name / 指标名称', example: 'commit_count' }

      expose :metric_detail, using: Entities::CommitCountMetricDetail,
             documentation: {
               type: 'CommitCountMetricDetail',
               desc: 'Commit Count Details / 提交数明细',
               param_type: 'body'
             }

      expose :version_number, documentation: { type: 'NilClass', desc: 'Version Number / 版本号', example: nil } # 新增字段
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'Metric Calculation Time / 指标计算时间', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'Metadata Update Time / 元数据更新时间',
                              example: '2025-05-14T07:28:30.512875+00:00' }
    end

    # 分页响应结构
    class CommitCountResponse < Grape::Entity
      expose :count, documentation: {
        type: 'Integer',
        desc: 'Total Records / 总记录数',
        example: 100
      }

      expose :total_page, documentation: {
        type: 'Integer',
        desc: 'Total Pages / 总页数',
        example: 2
      }

      expose :page, documentation: {
        type: 'Integer',
        desc: 'Current Page / 当前页码',
        example: 1
      }

      expose :items, using: Entities::CommitCountItem,
             documentation: {
               type: 'CommitCountItem',
               desc: 'Commit Records List / 提交记录列表',
               is_array: true,
               param_type: 'body'
             }
    end
  end
end
