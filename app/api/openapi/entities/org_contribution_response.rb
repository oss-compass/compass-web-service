# frozen_string_literal: true
module Openapi
  module Entities

    class OrgContributionRepoDetail < Grape::Entity
      expose :repo_url, documentation: {
        type: 'String',
        desc: '仓库URL',
        example: "https://github.com/oss-compass/compass-web-service"
      }
      expose :org_contribution_details, documentation: {
        type: 'Object',
        desc: '该仓库的组织贡献详情',
        example: {
          "org_contribution": 0.85,
          "personal": 0.15,
          "organization": 0.85
        }
      }
    end

    class OrgContributionMetricDetail < Grape::Entity
      expose :org_contribution, documentation: {
        type: 'Float',
        desc: '组织贡献度评分（0-1之间），表示项目中来自组织的贡献占比。数值越高表示组织贡献度越高，项目越倾向于组织主导。',
        example: 0.75
      }
      expose :org_contribution_details, using: Entities::OrgContributionRepoDetail, documentation: {
        type: 'Array[Entities::OrgContributionRepoDetail]',
        desc: '各仓库的组织贡献详情列表',
        is_array: true
      }
    end

    class OrgContributionItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: '唯一id', example: "a0ddde9c5ad5c6956e5a9662cc4859ad1abaf8b1" }
      expose :level, documentation: { type: 'String', desc: '仓库层级: 仓库repo/社区community', example: "repo" }
      expose :label, documentation: { type: 'String', desc: '仓库或社区标签', example: "https://github.com/oss-compass/compass-web-service" }
      expose :metric_type, documentation: { type: 'String', desc: '指标类型', example: "community_portrait" }
      expose :metric_name, documentation: { type: 'String', desc: '指标名称', example: "评估组织、机构对开源软件的贡献情况。" }
      expose :metric_detail, using: Entities::OrgContributionMetricDetail, documentation: {
        type: 'Entities::OrgContributionMetricDetail',
        desc: '指标详情',
        param_type: 'body'
      }
      expose :version_number, documentation: { type: 'String', desc: '版本号', example: "v2.0.0" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: '时间', example: "2023-04-12T06:18:01+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T03:27:03.506703+00:00" }
    end

    class OrgContributionResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::OrgContributionItem, documentation: {
        type: 'Entities::OrgContributionItem',
        desc: 'response',
        param_type: 'body',
        is_array: true
      }
    end

  end
end