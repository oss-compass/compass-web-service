# frozen_string_literal: true
module Openapi
  module Entities

    class CodeCommentMetrics < Grape::Entity
      expose :comment_ratio, documentation: { type: 'Float', desc: '注释比例', example: 0.15 }
      expose :comment_lines, documentation: { type: 'Integer', desc: '注释行数', example: 150 }
      expose :total_lines, documentation: { type: 'Integer', desc: '总行数', example: 1000 }
    end

    class CodeModularMetrics < Grape::Entity
      expose :function_count, documentation: { type: 'Integer', desc: '函数数量', example: 25 }
      expose :class_count, documentation: { type: 'Integer', desc: '类的数量', example: 5 }
    end

    class CodeReadabilityDetail < Grape::Entity
      expose :File, documentation: { type: 'String', desc: '文件路径', example: '/src/main/app.js' }
      expose :Language, documentation: { type: 'String', desc: '语言', example: 'JavaScript' }
      expose :Comment, using: Entities::CodeCommentMetrics, documentation: { type: 'Entities::CodeCommentMetrics', desc: '注释相关指标' }
      expose :Is_Modular, as: :is_modular, using: Entities::CodeModularMetrics, documentation: { type: 'Entities::CodeModularMetrics', desc: '模块化相关指标' }
      expose :blank_lines, documentation: { type: 'Integer', desc: '空白行数量', example: 100 }
      expose :avg_line_word_numbers, documentation: { type: 'Float', desc: '每行的平均单词数量', example: 8.5 }
      expose :avg_identifier_length, documentation: { type: 'Float', desc: '可识别单词的平均长度', example: 12.3 }
      expose :total_lines, documentation: { type: 'Integer', desc: '总行数', example: 1000 }
      expose :identifier_word_ratio, documentation: { type: 'Float', desc: '可识别单词的比例', example: 0.75 }
      expose :keyword_frequency, documentation: { type: 'Float', desc: '关键词的比例', example: 0.12 }
      expose :avg_identifiers_per_line, documentation: { type: 'Float', desc: '每行可识别单词的平均数量', example: 3.5 }
    end

    class CodeReadabilityMetricDetail < Grape::Entity
      expose :evaluate_code_readability, documentation: { type: 'Integer', desc: '代码可读性评分', example: 85 }
      expose :detail, using: Entities::CodeReadabilityDetail, documentation: {
        type: 'Array',
        desc: '代码可读性详细信息',
        param_type: 'body',
        is_array: true
      }
    end

    class CodeReadabilityItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: '唯一id', example: "a0ddde9c5ad5c6956e5a9662cc4859ad1abaf8b1" }
      expose :level, documentation: { type: 'String', desc: '仓库层级: 仓库repo/社区community', example: "repo" }
      expose :label, documentation: { type: 'String', desc: '仓库或社区标签', example: "https://github.com/oss-compass/compass-web-service" }
      expose :metric_type, documentation: { type: 'String', desc: '指标类型', example: "software_artifact_portrait" }
      expose :metric_name, documentation: { type: 'String', desc: '指标名称', example: "代码可读性" }
      expose :metric_detail, using: Entities::CodeReadabilityMetricDetail, documentation: { type: 'Entities::CodeReadabilityMetricDetail', desc: '指标详情', param_type: 'body'}
      expose :version_number, documentation: { type: 'String', desc: '版本号', example: "v2.0.0" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: '时间', example: "2023-04-12T06:18:01+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T03:27:03.506703+00:00" }
    end

    class CodeReadabilityResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::CodeReadabilityItem, documentation: {
        type: 'Entities::CodeReadabilityItem',
        desc: 'response',
        param_type: 'body',
        is_array: true
      }
    end

  end
end
