# frozen_string_literal: true

module Openapi
  module Entities
    class DeveloperBaseModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :total_active_contributors, documentation: { type: 'Integer', desc: 'Total active contributors / 社区贡献者数量', nullable: true }
      expose :code_contributors, documentation: { type: 'Integer', desc: 'Code contributors / 代码贡献者数量', nullable: true }
      expose :non_code_contributors, documentation: { type: 'Integer', desc: 'Non-code contributors / 非代码贡献者数量', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Developer Base 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class DeveloperBaseModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::DeveloperBaseModelDataItem,
             documentation: { type: 'DeveloperBaseModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end