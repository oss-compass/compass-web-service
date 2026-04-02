# frozen_string_literal: true

module Openapi
  module Entities
    class TrustedBuildModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :ecology_build_success_rate, documentation: { type: 'Float', desc: 'Ecology build success rate / 构建成功率', nullable: true }
      expose :build_checker_present, documentation: { type: 'Boolean', desc: 'Build checker present / 是否存在构建检查器', nullable: true }
      expose :ecology_ci, documentation: { type: 'String', desc: 'Ecology CI / CI集成状态', nullable: true }
      expose :ci_integration, documentation: { type: 'Boolean', desc: 'CI integration / 是否集成CI', nullable: true }
      expose :build_metadata_available, documentation: { type: 'Boolean', desc: 'Build metadata available / 构建元数据是否可获取', nullable: true }
      expose :detail, documentation: { type: 'String', desc: 'Detail / 详细信息', nullable: true }
      expose :reproducible_build, documentation: { type: 'Boolean', desc: 'Reproducible build / 是否为一致性构建', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Trusted Build 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class TrustedBuildModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::TrustedBuildModelDataItem,
             documentation: { type: 'TrustedBuildModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end