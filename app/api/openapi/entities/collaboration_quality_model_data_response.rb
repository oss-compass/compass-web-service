# frozen_string_literal: true

module Openapi
  module Entities
    class CollaborationQualityModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :pr_merge_ratio, documentation: { type: 'Float', desc: 'PR merge ratio / PR 合并率', nullable: true }
      expose :pr_merged_count, documentation: { type: 'Integer', desc: 'PR merged count / PR 合并数量', nullable: true }
      expose :pr_total_count, documentation: { type: 'Integer', desc: 'PR total count / PR 总数量', nullable: true }
      expose :pr_issue_linked_ratio, documentation: { type: 'Float', desc: 'PR issue linked ratio / PR/Issue 关联率', nullable: true }
      expose :pr_issue_linked_count, documentation: { type: 'Integer', desc: 'PR issue linked count / PR 关联 Issue 数量', nullable: true }
      expose :pr_review_participation_ratio, documentation: { type: 'Float', desc: 'PR review participation ratio / PR 评审参与率', nullable: true }
      expose :pr_with_review_count, documentation: { type: 'Integer', desc: 'PR with review count / 有评审的 PR 数量', nullable: true }
      expose :pr_non_author_merge_ratio, documentation: { type: 'Float', desc: 'PR non-author merge ratio / Non-author Merge Rate / Merge协作比率', nullable: true }
      expose :pr_non_author_merged_count, documentation: { type: 'Integer', desc: 'PR non-author merged count / 非作者合并的 PR 数量', nullable: true }
      expose :pr_merged_total_count, documentation: { type: 'Integer', desc: 'PR merged total count / PR 合并总数量', nullable: true }
      expose :pr_avg_interactions, documentation: { type: 'Float', desc: 'PR average interactions / PR 平均交互数', nullable: true }
      expose :pr_comments_total, documentation: { type: 'Integer', desc: 'PR comments total / PR 评论总数', nullable: true }
      expose :pr_review_time_by_size, documentation: { type: 'String', desc: 'Review Time by Pull Request Size / 分级代码审查时长', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Collaboration Quality 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class CollaborationQualityModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::CollaborationQualityModelDataItem,
             documentation: { type: 'CollaborationQualityModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
