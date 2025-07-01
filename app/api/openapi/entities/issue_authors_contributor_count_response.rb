# frozen_string_literal: true
module Openapi
  module Entities

    class IssueAuthorsContributorCountMetricDetail < Grape::Entity
      expose :issue_authors_contributor_count, documentation: {
        type: 'Integer',
        desc: 'Total Active Issue Authors in Last 90 Days/过去90天内的活跃Issue创建者总数',
        example: 55
      }
      expose :issue_authors_contributor_count_bot, documentation: {
        type: 'Integer',
        desc: 'Bot Issue Authors Count in Last 90 Days/过去90天内的机器人Issue创建者数量',
        example: 2
      }
      expose :issue_authors_contributor_count_without_bot, documentation: {
        type: 'Integer',
        desc: 'Human Issue Authors Count in Last 90 Days (Excluding Bots)/过去90天内的人类Issue创建者数量（不包括机器人）',
        example: 53
      }
    end

    class IssueAuthorsContributorCountItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'Unique ID/唯一id', example: "a0ddde9c5ad5c6956e5a9662cc4859ad1abaf8b1" }
      expose :level, documentation: { type: 'String', desc: 'Repository Level: repo/community/仓库层级: 仓库repo/社区community', example: "repo" }
      expose :label, documentation: { type: 'String', desc: 'Repository or Community Label/仓库或社区标签', example: "https://github.com/oss-compass/compass-web-service" }
      expose :metric_type, documentation: { type: 'String', desc: 'Metric Type/指标类型', example: "community_portrait" }
      expose :metric_name, documentation: { type: 'String', desc: 'Metric Name/指标名称', example: "Issue Authors Count Statistics/Issue创建者数量统计" }
      expose :metric_detail, using: Entities::IssueAuthorsContributorCountMetricDetail, documentation: {
        type: 'Entities::IssueAuthorsContributorCountMetricDetail',
        desc: 'Metric Details/指标详情',
        param_type: 'body'
      }
      expose :version_number, documentation: { type: 'String', desc: 'Version Number/版本号', example: "v2.0.0" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'Time/时间', example: "2023-04-12T06:18:01+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T03:27:03.506703+00:00" }
    end

    class IssueAuthorsContributorCountResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count/总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages/总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page/当前页', example: 1 }
      expose :items, using: Entities::IssueAuthorsContributorCountItem, documentation: {
        type: 'Entities::IssueAuthorsContributorCountItem',
        desc: 'response',
        param_type: 'body',
        is_array: true
      }
    end

  end
end
