# frozen_string_literal: true
module Openapi
  module Entities

    class OrgContributorCountDetail < Grape::Entity
      expose :org_name, documentation: {
        type: 'String',
        desc: 'Organization Name/组织名称',
        example: "OpenOrg"
      }
      expose :is_org, documentation: {
        type: 'Boolean',
        desc: 'Is Formal Organization (true) or Domain Only (false)/是否为正式组织（true）或仅为域名（false）',
        example: true
      }
      expose :org_contributor_count, documentation: {
        type: 'Integer',
        desc: 'Number of Contributors in this Organization/该组织的贡献者数量',
        example: 15
      }
    end

    class OrgContributorCountMetricDetail < Grape::Entity
      expose :org_contributor_count, documentation: {
        type: 'Integer',
        desc: 'Total Active Code Contributors with Organizational Affiliations in Last 90 Days/过去90天内有组织附属关系的活跃代码贡献者总数',
        example: 45
      }
      expose :org_contributor_count_bot, documentation: {
        type: 'Integer',
        desc: 'Number of Bot Code Contributors with Organizational Affiliations in Last 90 Days/过去90天内有组织附属关系的机器人代码贡献者数量',
        example: 2
      }
      expose :org_contributor_count_without_bot, documentation: {
        type: 'Integer',
        desc: 'Number of Human Code Contributors with Organizational Affiliations in Last 90 Days (Excluding Bots)/过去90天内有组织附属关系的人类代码贡献者数量（不包括机器人）',
        example: 43
      }
      expose :org_contributor_count_list, using: Entities::OrgContributorCountDetail, documentation: {
        type: 'Array[Entities::OrgContributorCountDetail]',
        desc: 'Organization Contributor Count Details List (Sorted by Contributor Count in Descending Order)/各组织的贡献者数量详情列表（按贡献者数量降序排序）',
        is_array: true
      }
    end

    class OrgContributorCountItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'Unique ID/唯一id', example: "a0ddde9c5ad5c6956e5a9662cc4859ad1abaf8b1" }
      expose :level, documentation: { type: 'String', desc: 'Repository Level: repo/community/仓库层级: 仓库repo/社区community', example: "repo" }
      expose :label, documentation: { type: 'String', desc: 'Repository or Community Label/仓库或社区标签', example: "https://github.com/oss-compass/compass-web-service" }
      expose :metric_type, documentation: { type: 'String', desc: 'Metric Type/指标类型', example: "community_portrait" }
      expose :metric_name, documentation: { type: 'String', desc: 'Metric Name/指标名称', example: "Organization Contributor Count Statistics" }
      expose :metric_detail, using: Entities::OrgContributorCountMetricDetail, documentation: {
        type: 'Entities::OrgContributorCountMetricDetail',
        desc: 'Metric Details/指标详情',
        param_type: 'body'
      }
      expose :version_number, documentation: { type: 'String', desc: 'Version Number/版本号', example: "v2.0.0" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'Time/时间', example: "2023-04-12T06:18:01+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T03:27:03.506703+00:00" }
    end

    class OrgContributorCountResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count/总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages/总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page/当前页', example: 1 }
      expose :items, using: Entities::OrgContributorCountItem, documentation: {
        type: 'Entities::OrgContributorCountItem',
        desc: 'response',
        param_type: 'body',
        is_array: true
      }
    end

  end
end
