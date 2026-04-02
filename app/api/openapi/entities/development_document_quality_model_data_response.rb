# frozen_string_literal: true

module Openapi
  module Entities
    class DevelopmentDocumentQualityModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :ecology_readme, documentation: { type: 'String', desc: 'Ecology readme / README文档质量', nullable: true }
      expose :ecology_readme_detail, documentation: { type: 'String', desc: 'Ecology readme detail / README文档质量详情', nullable: true }
      expose :readme_completeness_score, documentation: { type: 'Float', desc: 'Readme completeness score / README完整性得分', nullable: true }
      expose :ecology_readme_raw, documentation: { type: 'String', desc: 'Ecology readme raw / README原始数据', nullable: true }
      expose :ecology_build_doc, documentation: { type: 'String', desc: 'Ecology build doc / 构建文档质量', nullable: true }
      expose :ecology_build_doc_detail, documentation: { type: 'String', desc: 'Ecology build doc detail / 构建文档质量详情', nullable: true }
      expose :has_build_install_docs, documentation: { type: 'Boolean', desc: 'Has build install docs / 是否有构建安装文档', nullable: true }
      expose :ecology_interface_doc, documentation: { type: 'String', desc: 'Ecology interface doc / 接口文档质量', nullable: true }
      expose :ecology_interface_doc_detail, documentation: { type: 'String', desc: 'Ecology interface doc detail / 接口文档质量详情', nullable: true }
      expose :has_api_docs, documentation: { type: 'Boolean', desc: 'Has API docs / 是否有API文档', nullable: true }
      expose :committers_file_exists, documentation: { type: 'Boolean', desc: 'Committers file exists / 是否有Committers文件', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Development Document Quality 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class DevelopmentDocumentQualityModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::DevelopmentDocumentQualityModelDataItem,
             documentation: { type: 'DevelopmentDocumentQualityModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
