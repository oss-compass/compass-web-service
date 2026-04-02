# frozen_string_literal: true

module Openapi
  module Entities
    class OrganizationalGovernanceModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :participating_orgs, documentation: { type: 'Integer', desc: 'Participating orgs / 参与贡献的组织个数', nullable: true }
      expose :org_code_contributors, documentation: { type: 'Integer', desc: 'Org code contributors / 组织代码贡献者数量', nullable: true }
      expose :org_code_contributors_ratio, documentation: { type: 'Float', desc: 'Org code contributors ratio / 组织代码贡献者占比', nullable: true }
      expose :total_code_contributors, documentation: { type: 'Integer', desc: 'Total code contributors / 总代码贡献者数量', nullable: true }
      expose :org_code_contribution, documentation: { type: 'Integer', desc: 'Org code contribution / 组织代码贡献量', nullable: true }
      expose :org_code_contribution_ratio, documentation: { type: 'Float', desc: 'Org code contribution ratio / 组织代码贡献量占比', nullable: true }
      expose :total_code_contribution, documentation: { type: 'Integer', desc: 'Total code contribution / 总代码贡献量', nullable: true }
      expose :org_non_code_contributors, documentation: { type: 'Integer', desc: 'Org non-code contributors / 组织非代码贡献者数量', nullable: true }
      expose :org_non_code_contributors_ratio, documentation: { type: 'Float', desc: 'Org non-code contributors ratio / 组织非代码贡献者占比', nullable: true }
      expose :total_non_code_contributors, documentation: { type: 'Integer', desc: 'Total non-code contributors / 总非代码贡献者数量', nullable: true }
      expose :org_non_code_contribution, documentation: { type: 'Integer', desc: 'Org non-code contribution / 组织非代码贡献量', nullable: true }
      expose :org_non_code_contribution_ratio, documentation: { type: 'Float', desc: 'Org non-code contribution ratio / 组织非代码贡献量占比', nullable: true }
      expose :total_non_code_contribution, documentation: { type: 'Integer', desc: 'Total non-code contribution / 总非代码贡献量', nullable: true }
      expose :governance_orgs, documentation: { type: 'Integer', desc: 'Governance orgs / 参与治理的组织个数', nullable: true }
      expose :org_managers, documentation: { type: 'Integer', desc: 'Org managers / 组织管理者数量', nullable: true }
      expose :org_managers_ratio, documentation: { type: 'Float', desc: 'Org managers ratio / 组织管理者数量占比', nullable: true }
      expose :total_managers, documentation: { type: 'Integer', desc: 'Total managers / 总管理者数量', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Organizational Governance 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class OrganizationalGovernanceModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::OrganizationalGovernanceModelDataItem,
             documentation: { type: 'OrganizationalGovernanceModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end