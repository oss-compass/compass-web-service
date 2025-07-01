# frozen_string_literal: true

module Openapi
  module Entities
    # 提交频率指标详情
    class ActivityQuarterlyContributionMetricDetail < Grape::Entity
      expose :activity_quarterly_contribution,
             documentation: {
               type: 'Array[Float]',
               desc: 'Quarterly Contribution Distribution/季度贡献值分布',
               example: [],
               is_array: true
             }

      expose :activity_quarterly_contribution_bot,
             documentation: {
               type: 'Array[Float]',
               desc: 'Bot Quarterly Contribution Distribution/机器人季度贡献分布',
               example: [],
               is_array: true
             }

      expose :activity_quarterly_contribution_without_bot,
             documentation: {
               type: 'Array[Float]',
               desc: 'Non-bot Quarterly Contribution Distribution/非机器人季度贡献分布',
               example: [],
               is_array: true
             }

      expose :activity_quarterly_contribution_info,
             documentation: {
               type: 'String',
               desc: 'Data Retrieval Status Description/数据获取状态描述',
               example: 'Failed to obtain version release time',
               nullable: true
             }
    end

    # 单条提交频率记录
    class ActivityQuarterlyContributionItem < Grape::Entity
      expose :uuid, documentation: {
        type: 'String',
        desc: 'Unique Identifier/唯一标识符',
        example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55'
      }

      expose :level, documentation: {
        type: 'String',
        desc: 'Analysis Level/分析层级',
        example: 'repo',
        values: %w[repo org]
      }

      expose :label, documentation: {
        type: 'String',
        desc: 'Repository URL/仓库地址',
        example: 'https://github.com/oss-compass/compass-web-service'
      }

      expose :metric_type, documentation: {
        type: 'String',
        desc: 'Metric Category/指标分类',
        example: 'community_portrait'
      }

      expose :metric_name, documentation: {
        type: 'String',
        desc: 'Metric Name/指标名称',
        example: 'activity_quarterly_contribution'
      }

      expose :metric_detail, using: Entities::ActivityQuarterlyContributionMetricDetail,
             documentation: {
               type: 'ActivityQuarterlyContributionMetricDetail',
               desc: 'Contribution Frequency Detail/提交频率详情',
               param_type: 'body'
             }

      expose :grimoire_creation_date, documentation: {
        type: 'String',
        desc: 'Metric Calculation Time/指标计算时间',
        example: '2024-11-04T00:00:00+00:00'
      }

      expose :metadata__enriched_on, documentation: {
        type: 'String',
        desc: 'Metadata Update Time/元数据更新时间',
        example: '2025-05-14T07:28:30.512875+00:00'
      }
    end

    # 分页响应结构
    class ActivityQuarterlyContributionResponse < Grape::Entity
      expose :count, documentation: {
        type: 'Integer',
        desc: 'Total Records/总记录数',
        example: 100
      }

      expose :total_page, documentation: {
        type: 'Integer',
        desc: 'Total Pages/总页数',
        example: 2
      }

      expose :page, documentation: {
        type: 'Integer',
        desc: 'Current Page/当前页码',
        example: 1
      }

      expose :items, using: Entities::ActivityQuarterlyContributionItem,
             documentation: {
               type: 'ActivityQuarterlyContributionItem',
               desc: 'Contribution Records List/提交记录列表',
               is_array: true,
               param_type: 'body'
             }
    end
  end
end
