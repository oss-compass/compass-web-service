# frozen_string_literal: true

module Openapi
  module Entities
    # V3「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class V3MetricModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items,
             documentation: {
               type: 'Array',
               desc: 'Rows: uuid/level/type/label/model_name/period/grimoire_creation_date, module metric fields, and score / 行数据：基础字段、本模块指标字段与 score',
               is_array: true
             }
    end
  end
end
