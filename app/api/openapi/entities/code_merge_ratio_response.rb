# frozen_string_literal: true
# frozen_string_literal: true

module Openapi
  module Entities
    class CodeMergeRatioMetricDetail < Grape::Entity
      expose :code_merge_ratio,
             documentation: {
               type: 'Float',
               desc: 'Non-author Merge Ratio (Non-author Merges/Total Merges)/非作者合并比例（非作者合并次数/总合并次数）',
               example: 0.8571,
               format: 'float<0.0000-1.0000>',
               minimum: 0.0,
               maximum: 1.0,
               nullable: true,
               required: true
             }
    end

    class CodeMergeRatioItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'Unique Identifier/唯一标识符', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'Analysis Level/分析层级', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'Repository URL/仓库地址', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'Metric Type/指标类型', example: 'community_portrait' }
      expose :metric_name, documentation: { type: 'String', desc: 'Metric Name/指标名称', example: 'code_merge_ratio' }
      expose :metric_detail, using: Entities::CodeMergeRatioMetricDetail,
             documentation: { type: 'CodeMergeRatioMetricDetail', desc: 'Metric Details/指标详情' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'Version Number/版本号', example: nil } # 新增字段
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'Metric Calculation Time/指标计算时间', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'Metadata Update Time/元数据更新时间',
                              example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class CodeMergeRatioResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Records/总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages/总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page/当前页', example: 1 }
      expose :items, using: Entities::CodeMergeRatioItem,
             documentation: { type: 'Entities::CodeMergeRatioItem', desc: 'Response Items/响应项', param_type: 'body', is_array: true }
    end
  end
end
