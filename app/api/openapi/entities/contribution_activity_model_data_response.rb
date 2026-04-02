# frozen_string_literal: true

module Openapi
  module Entities
    class ContributionActivityModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :commit_count, documentation: { type: 'Integer', desc: 'Commit count / 提交数量', nullable: true }
      expose :lines_added, documentation: { type: 'Integer', desc: 'Lines added / 新增代码行数', nullable: true }
      expose :lines_removed, documentation: { type: 'Integer', desc: 'Lines removed / 删除代码行数', nullable: true }
      expose :pr_comment_count, documentation: { type: 'Integer', desc: 'PR comment count / PR 评论数量', nullable: true }
      expose :issue_new_count, documentation: { type: 'Integer', desc: 'Issue new count / 新增 Issue 数量', nullable: true }
      expose :issue_comment_activity, documentation: { type: 'Integer', desc: 'Issue comment activity / Issue 评论活跃度', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Contribution Activity 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class ContributionActivityModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::ContributionActivityModelDataItem,
             documentation: { type: 'ContributionActivityModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end