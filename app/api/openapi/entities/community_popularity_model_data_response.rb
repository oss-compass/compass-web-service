# frozen_string_literal: true

module Openapi
  module Entities
    class CommunityPopularityModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :stars_added, documentation: { type: 'Integer', desc: 'Stars added / 项目Stars新增', nullable: true }
      expose :stars_total, documentation: { type: 'Integer', desc: 'Stars total / 项目Stars总数', nullable: true }
      expose :forks_added, documentation: { type: 'Integer', desc: 'Forks added / 项目Forks新增', nullable: true }
      expose :forks_total, documentation: { type: 'Integer', desc: 'Forks total / 项目Forks总数', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Community Popularity 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class CommunityPopularityModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::CommunityPopularityModelDataItem,
             documentation: { type: 'CommunityPopularityModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end