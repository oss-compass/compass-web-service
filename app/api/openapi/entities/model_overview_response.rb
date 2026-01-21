# frozen_string_literal: true
module Openapi
  module Entities

    class OverviewItem < Grape::Entity

      expose :dimension, documentation: { type: 'String', desc: 'Dimension / 维度', example: "robustness" }
      expose :ident, documentation: { type: 'String', desc: 'Identifier / 标识', example: "activity" }
      expose :scope, documentation: { type: 'String', desc: 'Scope / 范围', example: "collaboration" }
      expose :type, documentation: { type: 'String', desc: 'Type / 类型', example: nil }
      expose :label, documentation: { type: 'String', desc: 'Label / 标签 (URL)', example: "https://github.com/apple/foundationdb" }
      expose :level, documentation: { type: 'String', desc: 'Level / 级别', example: "repo" }
      expose :main_score, documentation: { type: 'Float', desc: 'Main Score / 原始分数', example: 0.03919 }
      expose :transformed_score, documentation: { type: 'Integer', desc: 'Transformed Score / 转换后分数', example: 23 }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'Creation Date / 创建时间', example: "2025-05-12T00:00:00+00:00" }
      expose :updated_at, documentation: { type: 'String', desc: 'Updated At / 更新时间', example: "2025-05-13T17:56:10+00:00" }
      expose :repos_count, documentation: { type: 'Integer', desc: 'Repos Count / 仓库数量', example: 1 }
      expose :short_code, documentation: { type: 'String', desc: 'Short Code / 短码', example: "sn7b929e" }

    end

    class ModelOverviewResponse < Grape::Entity
      expose :code, documentation: { type: 'Integer', desc: 'Status Code', example: 201 }
      expose :message, documentation: { type: 'String', desc: 'Message', example: "Success" }
      expose :data, using: Entities::OverviewItem, documentation: { type: 'Entities::OverviewItem', desc: 'Response Items/响应项',
                                                                     param_type: 'body', is_array: true }

    end

  end
end
