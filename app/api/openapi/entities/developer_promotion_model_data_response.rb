# frozen_string_literal: true

module Openapi
  module Entities
    class DeveloperPromotionModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :org_code_core_promotion_count, documentation: { type: 'Integer', desc: 'Org code core promotion count / 组织代码核心晋升数量', nullable: true }
      expose :org_issue_core_promotion_count, documentation: { type: 'Integer', desc: 'Org issue core promotion count / 组织Issue核心晋升数量', nullable: true }
      expose :individual_code_core_promotion_count, documentation: { type: 'Integer', desc: 'Individual code core promotion count / 个人代码核心晋升数量', nullable: true }
      expose :individual_issue_core_promotion_count, documentation: { type: 'Integer', desc: 'Individual issue core promotion count / 个人Issue核心晋升数量', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Developer Promotion 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class DeveloperPromotionModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::DeveloperPromotionModelDataItem,
             documentation: { type: 'DeveloperPromotionModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end