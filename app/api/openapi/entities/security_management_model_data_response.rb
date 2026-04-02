# frozen_string_literal: true

module Openapi
  module Entities
    class SecurityManagementModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :vulnerability_disclosure_has_channel, documentation: { type: 'Boolean', desc: 'Vulnerability disclosure has channel / 漏洞响应与披露渠道', nullable: true }
      expose :security_md_exists, documentation: { type: 'Boolean', desc: 'Security MD exists / 安全文档存在', nullable: true }
      expose :avg_vuln_close_days, documentation: { type: 'Float', desc: 'Avg vuln close days / 平均漏洞关闭天数', nullable: true }
      expose :vulnerability_disclosure_detail, documentation: { type: 'String', desc: 'Vulnerability disclosure detail / 漏洞响应与披露详情', nullable: true }
      expose :security_vulnerability, documentation: { type: 'String', desc: 'Security vulnerability / 公开未修复漏洞', nullable: true }
      expose :security_vulnerability_detail, documentation: { type: 'String', desc: 'Security vulnerability detail / 公开未修复漏洞详情', nullable: true }
      expose :vuln_counts, documentation: { type: 'String', desc: 'Vuln counts / 漏洞计数', nullable: true }
      expose :security_vulnerability_raw, documentation: { type: 'String', desc: 'Security vulnerability raw / 漏洞原始数据', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Security Management 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class SecurityManagementModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::SecurityManagementModelDataItem,
             documentation: { type: 'SecurityManagementModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
