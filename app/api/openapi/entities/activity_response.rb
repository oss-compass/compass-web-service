# frozen_string_literal: true
module Openapi
  module Entities

    class ActivityItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'Unique Identifier / 唯一标识符', example: "9497744d49ae8c0eba2b657d55a178a4b12c2b77" }
      expose :level, documentation: { type: 'String', desc: 'Analysis Level / 分析层级', example: "repo" }
      expose :type, documentation: { type: 'String', desc: 'Type / 类型', example: '' }
      expose :label, documentation: { type: 'String', desc: 'Repository URL / 仓库地址', example: "https://github.com/oss-compass/compass-web-service" }
      expose :model_name, documentation: { type: 'String', desc: 'Model Name / 模型名称', example: "Activity" }
      expose :contributor_count, documentation: { type: 'Integer', desc: 'Contributor Count / 贡献者数量', example: 1 }
      expose :contributor_count_bot, documentation: { type: 'Integer', desc: 'Bot Contributor Count / 机器人贡献者数量', example: 0 }
      expose :contributor_count_without_bot, documentation: { type: 'Integer', desc: 'Non-bot Contributor Count / 非机器人贡献者数量', example: 1 }
      expose :active_C2_contributor_count, documentation: { type: 'Integer', desc: 'Active C2 Contributor Count / 活跃C2贡献者数量', example: 1 }
      expose :active_C1_pr_create_contributor, documentation: { type: 'Integer', desc: 'Active C1 PR Creator Count / 活跃C1 PR创建者数量', example: 0 }
      expose :active_C1_pr_comments_contributor, documentation: { type: 'Integer', desc: 'Active C1 PR Commenter Count / 活跃C1 PR评论者数量', example: 0 }
      expose :active_C1_issue_create_contributor, documentation: { type: 'Integer', desc: 'Active C1 Issue Creator Count / 活跃C1 Issue创建者数量', example: 0 }
      expose :active_C1_issue_comments_contributor, documentation: { type: 'Integer', desc: 'Active C1 Issue Commenter Count / 活跃C1 Issue评论者数量', example: 0 }
      expose :commit_frequency, documentation: { type: 'Float', desc: 'Commit Frequency / 提交频率', example: 0.07782101167315175 }
      expose :commit_frequency_bot, documentation: { type: 'Integer', desc: 'Bot Commit Frequency / 机器人提交频率', example: 0 }
      expose :commit_frequency_without_bot, documentation: { type: 'Float', desc: 'Non-bot Commit Frequency / 非机器人提交频率', example: 0.07782101167315175 }
      expose :org_count, documentation: { type: 'Integer', desc: 'Organization Count / 组织数量', example: 0 }
      expose :comment_frequency, documentation: { type: 'String', desc: 'Comment Frequency / 评论频率', example: '' }
      expose :code_review_count, documentation: { type: 'String', desc: 'Code Review Count / 代码审查数量', example: '' }
      expose :updated_since, documentation: { type: 'Float', desc: 'Updated Since / 更新时长', example: 0.12 }
      expose :closed_issues_count, documentation: { type: 'Integer', desc: 'Closed Issues Count / 已关闭Issue数量', example: 0 }
      expose :updated_issues_count, documentation: { type: 'Integer', desc: 'Updated Issues Count / 已更新Issue数量', example: 0 }
      expose :recent_releases_count, documentation: { type: 'Integer', desc: 'Recent Releases Count / 最近发布数量', example: 0 }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'Metric Calculation Time / 指标计算时间', example: "2022-07-18T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'Metadata Update Time / 元数据更新时间', example: "2024-01-17T22:47:46.075025+00:00" }
      expose :activity_score, documentation: { type: 'Float', desc: 'Activity Score / 活跃度得分', example: 0.10004935969506674 }
      #
    end

    class ActivityResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Records/总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages/总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page/当前页', example: 1 }
      expose :items, using: Entities::ActivityItem, documentation: { type: 'Entities::ActivityItem', desc: 'Response Items/响应项',
                                                                     param_type: 'body', is_array: true }

    end

  end
end
