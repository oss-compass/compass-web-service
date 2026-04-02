# frozen_string_literal: true

module Openapi
  module Entities
    class CodeReviewQualityModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :dependency_reachable_ok, documentation: { type: 'Boolean', desc: 'Dependency reachable ok / 依赖可获得状态', nullable: true }
      expose :dependency_unreachable_list, documentation: { type: 'Array', desc: 'Dependency unreachable list / 不可获得的依赖列表', nullable: true }
      expose :detail, documentation: { type: 'String', desc: 'Detail / 详细信息', nullable: true }
      expose :compliance_snippet_reference, documentation: { type: 'String', desc: 'Compliance snippet reference / 片段引用合规性', nullable: true }
      expose :compliance_snippet_reference_detail, documentation: { type: 'String', desc: 'Compliance snippet reference detail / 片段引用合规性详情', nullable: true }
      expose :violation_count, documentation: { type: 'Integer', desc: 'Violation count / 违规数量', nullable: true }
      expose :patent_risk_level, documentation: { type: 'String', desc: 'Patent risk level / 专利风险等级', nullable: true }
      expose :patent_risk_unavailable, documentation: { type: 'Boolean', desc: 'Patent risk unavailable / 专利风险不可用', nullable: true }
      expose :patent_risk_detail, documentation: { type: 'String', desc: 'Patent risk detail / 专利风险详情', nullable: true }
      expose :ecology_test_coverage, documentation: { type: 'String', desc: 'Ecology test coverage / 测试覆盖度', nullable: true }
      expose :ecology_test_coverage_detail, documentation: { type: 'String', desc: 'Ecology test coverage detail / 测试覆盖度详情', nullable: true }
      expose :test_coverage_percent, documentation: { type: 'Float', desc: 'Test coverage percent / 测试覆盖率百分比', nullable: true }
      expose :ecology_test_coverage_raw, documentation: { type: 'Object', desc: 'Ecology test coverage raw / 测试覆盖度原始数据', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Code Review Quality 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class CodeReviewQualityModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::CodeReviewQualityModelDataItem,
             documentation: { type: 'CodeReviewQualityModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end