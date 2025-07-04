# frozen_string_literal: true
module Openapi
  module Entities

    class CollaborationDevelopmentIndexItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'Unique Identifier / 唯一标识符', example: "e687b01abc5ffd9a0bbf0fed75b5d8a65ff9b561" }
      expose :level, documentation: { type: 'String', desc: 'Analysis Level / 分析层级', example: "repo" }
      expose :type, documentation: { type: 'String', desc: 'Type / 类型', example: '' }
      expose :label, documentation: { type: 'String', desc: 'Repository URL / 仓库地址', example: "https://github.com/oss-compass/compass-web-service" }
      expose :model_name, documentation: { type: 'String', desc: 'Model Name / 模型名称', example: "Code_Quality_Guarantee" }
      expose :contributor_count, documentation: { type: 'Integer', desc: 'Total Contributors / 贡献者总数', example: 1 }
      expose :contributor_count_bot, documentation: { type: 'Integer', desc: 'Bot Contributors / 机器人贡献者数', example: 0 }
      expose :contributor_count_without_bot, documentation: { type: 'Integer', desc: 'Human Contributors / 人类贡献者数', example: 1 }
      expose :active_C2_contributor_count, documentation: { type: 'Integer', desc: 'Active C2 Contributors / 活跃C2级贡献者数', example: 1 }
      expose :active_C1_pr_create_contributor, documentation: { type: 'Integer', desc: 'Active C1 PR Authors / 活跃C1级PR创建者数', example: 0 }
      expose :active_C1_pr_comments_contributor, documentation: { type: 'Integer', desc: 'Active C1 PR Commenters / 活跃C1级PR评论者数', example: 0 }
      expose :commit_frequency, documentation: { type: 'Float', desc: 'Commit Frequency / 提交频率', example: 0.07782101167315175 }
      expose :commit_frequency_bot, documentation: { type: 'Integer', desc: 'Bot Commit Frequency / 机器人提交频率', example: 0 }
      expose :commit_frequency_without_bot, documentation: { type: 'Float', desc: 'Human Commit Frequency / 人类提交频率', example: 0.07782101167315175 }
      expose :commit_frequency_inside, documentation: { type: 'Integer', desc: 'Internal Commit Frequency / 内部提交频率', example: 0 }
      expose :commit_frequency_inside_bot, documentation: { type: 'Integer', desc: 'Internal Bot Commit Frequency / 内部机器人提交频率', example: 0 }
      expose :commit_frequency_inside_without_bot, documentation: { type: 'Integer', desc: 'Internal Human Commit Frequency / 内部人类提交频率', example: 0 }
      expose :is_maintained, documentation: { type: 'Integer', desc: 'Maintenance Status / 维护状态', example: 0 }
      expose :LOC_frequency, documentation: { type: 'Float', desc: 'Lines of Code Change Frequency / 代码行变更频率', example: 562.9571984435797 }
      expose :lines_added_frequency, documentation: { type: 'Float', desc: 'Lines Added Frequency / 添加行数频率', example: 562.9571984435797 }
      expose :lines_removed_frequency, documentation: { type: 'Integer', desc: 'Lines Removed Frequency / 删除行数频率', example: 0 }
      expose :pr_issue_linked_ratio, documentation: { type: 'String', desc: 'PR-Issue Link Ratio / PR-Issue关联比率', example: '' }
      expose :code_review_ratio, documentation: { type: 'String', desc: 'Code Review Ratio / 代码审查比率', example: '' }
      expose :code_merge_ratio, documentation: { type: 'String', desc: 'Code Merge Ratio / 代码合并比率', example: '' }
      expose :pr_count, documentation: { type: 'Integer', desc: 'PR Count / PR数量', example: 0 }
      expose :pr_merged_count, documentation: { type: 'Integer', desc: 'Merged PR Count / 已合并PR数量', example: 0 }
      expose :pr_commit_count, documentation: { type: 'Integer', desc: 'PR Commit Count / PR提交数量', example: 1 }
      expose :pr_commit_linked_count, documentation: { type: 'Integer', desc: 'PR-Linked Commit Count / PR关联提交数量', example: 0 }
      expose :git_pr_linked_ratio, documentation: { type: 'Integer', desc: 'Git-PR Link Ratio / Git-PR关联比率', example: 0 }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'Metric Calculation Time / 指标计算时间', example: "2022-07-18T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'Metadata Update Time / 元数据更新时间', example: "2024-01-17T22:48:12.417052+00:00" }
      expose :code_quality_guarantee, documentation: { type: 'Float', desc: 'Code Quality Guarantee / 代码质量保证', example: 0.05017 }

    end

    class CollaborationDevelopmentIndexResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Records / 总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::CollaborationDevelopmentIndexItem, documentation: { type: 'Entities::CollaborationDevelopmentIndexItem', desc: 'Response Items / 响应项',
                                                                                          param_type: 'body', is_array: true }

    end

  end
end
