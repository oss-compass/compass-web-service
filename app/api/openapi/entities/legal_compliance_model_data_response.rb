# frozen_string_literal: true

module Openapi
  module Entities
    class LegalComplianceModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :compliance_copyright_statement, documentation: { type: 'String', desc: 'Compliance copyright statement / 许可头与版权声明', nullable: true }
      expose :compliance_copyright_statement_detail, documentation: { type: 'String', desc: 'Compliance copyright statement detail / 许可头与版权声明详情', nullable: true }
      expose :license_included_osi, documentation: { type: 'Boolean', desc: 'License included OSI / 许可证包含（OSI）', nullable: true }
      expose :compliance_license_compatibility, documentation: { type: 'String', desc: 'Compliance license compatibility / 许可证兼容性', nullable: true }
      expose :compliance_license_compatibility_detail, documentation: { type: 'String', desc: 'Compliance license compatibility detail / 许可证兼容性详情', nullable: true }
      expose :license_compatibility_conflicts, documentation: { type: 'Array', desc: 'License compatibility conflicts / 许可证兼容性冲突', nullable: true }
      expose :compliance_copyright_statement_anti_tamper, documentation: { type: 'String', desc: 'Compliance copyright statement anti tamper / 许可证与版权声明防篡改', nullable: true }
      expose :compliance_copyright_statement_anti_tamper_detail, documentation: { type: 'String', desc: 'Compliance copyright statement anti tamper detail / 许可证与版权声明防篡改详情', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Legal Compliance 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class LegalComplianceModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::LegalComplianceModelDataItem,
             documentation: { type: 'LegalComplianceModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end