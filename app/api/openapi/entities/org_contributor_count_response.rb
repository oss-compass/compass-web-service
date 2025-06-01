# frozen_string_literal: true
module Openapi
  module Entities

    class OrgContributorCountDetail < Grape::Entity
      expose :org_name, documentation: {
        type: 'String',
        desc: '组织名称',
        example: "OpenOrg"
      }
      expose :is_org, documentation: {
        type: 'Boolean',
        desc: '是否为正式组织（true）或仅为域名（false）',
        example: true
      }
      expose :org_contributor_count, documentation: {
        type: 'Integer',
        desc: '该组织的贡献者数量',
        example: 15
      }
    end

    class OrgContributorCountMetricDetail < Grape::Entity
      expose :org_contributor_count, documentation: {
        type: 'Integer',
        desc: '过去90天内有组织附属关系的活跃代码贡献者总数',
        example: 45
      }
      expose :org_contributor_count_bot, documentation: {
        type: 'Integer',
        desc: '过去90天内有组织附属关系的机器人代码贡献者数量',
        example: 2
      }
      expose :org_contributor_count_without_bot, documentation: {
        type: 'Integer',
        desc: '过去90天内有组织附属关系的人类代码贡献者数量（不包括机器人）',
        example: 43
      }
      expose :org_contributor_count_list, using: Entities::OrgContributorCountDetail, documentation: {
        type: 'Array[Entities::OrgContributorCountDetail]',
        desc: '各组织的贡献者数量详情列表（按贡献者数量降序排序）',
        is_array: true
      }
    end

    class OrgContributorCountItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: '唯一id', example: "a0ddde9c5ad5c6956e5a9662cc4859ad1abaf8b1" }
      expose :level, documentation: { type: 'String', desc: '仓库层级: 仓库repo/社区community', example: "repo" }
      expose :label, documentation: { type: 'String', desc: '仓库或社区标签', example: "https://github.com/oss-compass/compass-web-service" }
      expose :metric_type, documentation: { type: 'String', desc: '指标类型', example: "community_portrait" }
      expose :metric_name, documentation: { type: 'String', desc: '指标名称', example: "组织贡献者数量统计" }
      expose :metric_detail, using: Entities::OrgContributorCountMetricDetail, documentation: {
        type: 'Entities::OrgContributorCountMetricDetail',
        desc: '指标详情',
        param_type: 'body'
      }
      expose :version_number, documentation: { type: 'String', desc: '版本号', example: "v2.0.0" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: '时间', example: "2023-04-12T06:18:01+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T03:27:03.506703+00:00" }
    end

    class OrgContributorCountResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::OrgContributorCountItem, documentation: {
        type: 'Entities::OrgContributorCountItem',
        desc: 'response',
        param_type: 'body',
        is_array: true
      }
    end

  end
end
