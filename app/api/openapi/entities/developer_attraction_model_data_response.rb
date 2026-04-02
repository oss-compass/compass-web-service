# frozen_string_literal: true

module Openapi
  module Entities
    class DeveloperAttractionModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :new_org_count, documentation: { type: 'Integer', desc: 'New org count / 新增组织数', nullable: true }
      expose :new_org_code_contributors, documentation: { type: 'Integer', desc: 'New org code contributors / 新增组织代码开发者数量', nullable: true }
      expose :new_org_non_code_contributors, documentation: { type: 'Integer', desc: 'New org non-code contributors / 新增组织非代码开发者数量', nullable: true }
      expose :new_individual_code_contributors, documentation: { type: 'Integer', desc: 'New individual code contributors / 新增个人代码开发者数量', nullable: true }
      expose :new_individual_non_code_contributors, documentation: { type: 'Integer', desc: 'New individual non-code contributors / 新增个人非代码开发者数量', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Developer Attraction 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class DeveloperAttractionModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::DeveloperAttractionModelDataItem,
             documentation: { type: 'DeveloperAttractionModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end