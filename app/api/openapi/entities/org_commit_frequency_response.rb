# frozen_string_literal: true
module Openapi
  module Entities

    class OrgCommitFrequencyDetail < Grape::Entity
      expose :org_name, documentation: {
        type: 'String',
        desc: 'Organization Name / 组织名称',
        example: "OpenOrg"
      }
      expose :is_org, documentation: {
        type: 'Boolean',
        desc: 'Is Formal Organization (true) or Domain Only (false) / 是否为正式组织（true）或仅为域名（false）',
        example: true
      }
      expose :org_commit, documentation: {
        type: 'Integer',
        desc: 'Organization Commit Count / 该组织的提交次数',
        example: 120
      }
      expose :org_commit_percentage_by_org, documentation: {
        type: 'Float',
        desc: 'Organization Commit Percentage Among All Organizations / 该组织的提交占所有组织提交的百分比',
        example: 0.2500
      }
      expose :org_commit_percentage_by_total, documentation: {
        type: 'Float',
        desc: 'Organization Commit Percentage of Total Commits / 该组织的提交占总提交数的百分比',
        example: 0.1800
      }
    end

    class OrgCommitFrequencyMetricDetail < Grape::Entity
      expose :org_commit_frequency, documentation: {
        type: 'Float',
        desc: 'Average Weekly Organization Commits in Last 90 Days / 过去90天内平均每周有组织归属的代码提交次数',
        example: 15.5642
      }
      expose :org_commit_frequency_bot, documentation: {
        type: 'Float',
        desc: 'Average Weekly Bot Commits by Organization in Last 90 Days / 过去90天内平均每周有组织归属的机器人代码提交次数',
        example: 2.3346
      }
      expose :org_commit_frequency_without_bot, documentation: {
        type: 'Float',
        desc: 'Average Weekly Human Commits by Organization in Last 90 Days (Excluding Bots) / 过去90天内平均每周有组织归属的人类代码提交次数（不包括机器人）',
        example: 13.2296
      }
      expose :org_commit_frequency_list, using: Entities::OrgCommitFrequencyDetail, documentation: {
        type: 'Array[Entities::OrgCommitFrequencyDetail]',
        desc: 'Organization Commit Details List (Sorted by Commit Count in Descending Order) / 各组织的提交详情列表（按提交次数降序排序）',
        is_array: true
      }
    end

    class OrgCommitFrequencyItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'Unique ID / 唯一id', example: "a0ddde9c5ad5c6956e5a9662cc4859ad1abaf8b1" }
      expose :level, documentation: { type: 'String', desc: 'Repository Level: repo/community / 仓库层级: 仓库repo/社区community', example: "repo" }
      expose :label, documentation: { type: 'String', desc: 'Repository or Community Label / 仓库或社区标签', example: "https://github.com/oss-compass/compass-web-service" }
      expose :metric_type, documentation: { type: 'String', desc: 'Metric Type / 指标类型', example: "community_portrait" }
      expose :metric_name, documentation: { type: 'String', desc: 'Metric Name / 指标名称', example: "Organization Commit Frequency Statistics" }
      expose :metric_detail, using: Entities::OrgCommitFrequencyMetricDetail, documentation: {
        type: 'Entities::OrgCommitFrequencyMetricDetail',
        desc: 'Metric Details/指标详情',
        param_type: 'body'
      }
      expose :version_number, documentation: { type: 'String', desc: 'Version Number / 版本号', example: "v2.0.0" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'Time / 时间', example: "2023-04-12T06:18:01+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T03:27:03.506703+00:00" }
    end

    class OrgCommitFrequencyResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::OrgCommitFrequencyItem, documentation: {
        type: 'Entities::OrgCommitFrequencyItem',
        desc: 'response',
        param_type: 'body',
        is_array: true
      }
    end

  end
end
