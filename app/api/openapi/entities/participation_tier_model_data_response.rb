# frozen_string_literal: true

module Openapi
  module Entities
    class ParticipationTierModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :org_code_core_contributors, documentation: { type: 'Integer', desc: 'Org code core contributors / 组织代码核心开发者（含管理者）数量', nullable: true }
      expose :org_issue_core_contributors, documentation: { type: 'Integer', desc: 'Org issue core contributors / 组织Issue核心开发者（含管理者）数量', nullable: true }
      expose :org_code_regular_contributors, documentation: { type: 'Integer', desc: 'Org code regular contributors / 组织代码常客开发者数量', nullable: true }
      expose :org_issue_regular_contributors, documentation: { type: 'Integer', desc: 'Org issue regular contributors / 组织Issue常客开发者数量', nullable: true }
      expose :org_code_visitor_contributors, documentation: { type: 'Integer', desc: 'Org code visitor contributors / 组织代码访客开发者数量', nullable: true }
      expose :org_issue_visitor_contributors, documentation: { type: 'Integer', desc: 'Org issue visitor contributors / 组织Issue访客开发者数量', nullable: true }
      expose :individual_code_core_contributors, documentation: { type: 'Integer', desc: 'Individual code core contributors / 个人代码核心开发者（含管理者）数量', nullable: true }
      expose :individual_issue_core_contributors, documentation: { type: 'Integer', desc: 'Individual issue core contributors / 个人Issue核心开发者（含管理者）数量', nullable: true }
      expose :individual_code_regular_contributors, documentation: { type: 'Integer', desc: 'Individual code regular contributors / 个人代码常客开发者数量', nullable: true }
      expose :individual_issue_regular_contributors, documentation: { type: 'Integer', desc: 'Individual issue regular contributors / 个人Issue常客开发者数量', nullable: true }
      expose :individual_code_visitor_contributors, documentation: { type: 'Integer', desc: 'Individual code visitor contributors / 个人代码访客开发者数量', nullable: true }
      expose :individual_issue_visitor_contributors, documentation: { type: 'Integer', desc: 'Individual issue visitor contributors / 个人Issue访客开发者数量', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Participation Tier 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class ParticipationTierModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::ParticipationTierModelDataItem,
             documentation: { type: 'ParticipationTierModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end