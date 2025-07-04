# frozen_string_literal: true
module Openapi
  module Entities

    class CodeMergeCountWithNonAuthorMetricDetail < Grape::Entity
      expose :code_merge_count_with_non_author, documentation: {
        type: 'Integer',
        desc: 'Number of PRs Merged by Non-authors in Last 90 Days / 过去90天内由非作者合并的PR数量',
        example: 42
      }
    end

    class CodeMergeCountWithNonAuthorItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'Unique Identifier / 唯一标识符', example: "a0ddde9c5ad5c6956e5a9662cc4859ad1abaf8b1" }
      expose :level, documentation: { type: 'String', desc: 'Analysis Level: repo/community / 仓库层级: 仓库/社区', example: "repo" }
      expose :label, documentation: { type: 'String', desc: 'Repository or Community Label / 仓库或社区标签', example: "https://github.com/oss-compass/compass-web-service" }
      expose :metric_type, documentation: { type: 'String', desc: 'Metric Type / 指标类型', example: "community_portrait" }
      expose :metric_name, documentation: { type: 'String', desc: 'Metric Name / 指标名称', example: "non_author_code_merge_statistics" }
      expose :metric_detail, using: Entities::CodeMergeCountWithNonAuthorMetricDetail, documentation: {
        type: 'Entities::CodeMergeCountWithNonAuthorMetricDetail',
        desc: 'Metric Details / 指标详情',
        param_type: 'body'
      }
      expose :version_number, documentation: { type: 'String', desc: 'Version Number / 版本号', example: "v2.0.0" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'Creation Time / 创建时间', example: "2023-04-12T06:18:01+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T03:27:03.506703+00:00" }
    end

    class CodeMergeCountWithNonAuthorResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Records / 总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::CodeMergeCountWithNonAuthorItem, documentation: {
        type: 'Entities::CodeMergeCountWithNonAuthorItem',
        desc: 'Response Items / 响应项',
        param_type: 'body',
        is_array: true
      }
    end

  end
end
