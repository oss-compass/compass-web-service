# frozen_string_literal: true
module Openapi
  module Entities

    class CriticalityScoreResponse < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'Unique Identifier / 唯一标识符', example: "9497744d49ae8c0eba2b657d55a178a4b12c2b77" }
      expose :level, documentation: { type: 'String', desc: 'Analysis Level / 分析层级', example: "repo" }
      expose :type, documentation: { type: 'String', desc: 'Type / 类型', example: '' }
      expose :label, documentation: { type: 'String', desc: 'Repository URL / 仓库地址', example: "https://github.com/oss-compass/compass-web-service" }
      expose :model_name, documentation: { type: 'String', desc: 'Model Name / 模型名称', example: "Criticality Score" }

      expose :score, documentation: { type: 'Float', desc: 'score of criticality score / criticality score 得分', example: 1}
      expose :created_since, documentation: { type: 'Float', desc: 'Time since the project was created (in months) / 自项目创建以来的时间（以月为单位）', example: 1}
      expose :updated_since, documentation: { type: 'Float', desc: 'Time since the project was last updated (in months) / 自项目上次更新以来的时间（以月为单位）', example: 1}
      expose :contributor_count_all, documentation: { type: 'Float', desc: 'Count of project contributors (with commits) / 项目有代码提交的贡献者数量', example: 1}
      expose :org_count_all, documentation: { type: 'Float', desc: 'Count of distinct organizations that contributors belong to / 贡献者所属的不同组织的数量', example: 1}
      expose :commit_frequency_last_year, documentation: { type: 'Float', desc: 'Average number of commits per week in the last year / 过去1年每周平均提交次数', example: 1}
      expose :recent_releases_count, documentation: { type: 'Float', desc: 'Number of releases in the last year / 过去1年发布数量', example: 1}
      expose :closed_issues_count, documentation: { type: 'Float', desc: 'Number of issues closed in the last 90 days / 过去 90 天内解决的问题数', example: 1}
      expose :updated_issues_count, documentation: { type: 'Float', desc: 'Number of issues updated in the last 90 days / 过去 90 天内更新的问题数', example: 1}
      expose :comment_frequency, documentation: { type: 'Float', desc: 'Average number of comments per issue in the last 90 days / 过去 90 天内每期的平均评论数', example: 1}
      expose :dependents_count, documentation: { type: 'Float', desc: 'Number of project mentions in the commit messages / 提交消息中提及项目的数量', example: 1}

      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'Metric Calculation Time / 指标计算时间', example: "2022-07-18T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'Metadata Update Time / 元数据更新时间', example: "2024-01-17T22:47:46.075025+00:00" }

    end

  end
end
