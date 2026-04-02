# frozen_string_literal: true

module Openapi
  module Entities
    class ReleaseQualityModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :sbom_in_release, documentation: { type: 'Boolean', desc: 'SBOM in release / SBOM检查', nullable: true }
      expose :detail, documentation: { type: 'String', desc: 'Detail / 详细信息', nullable: true }
      expose :security_binary_artifact, documentation: { type: 'String', desc: 'Security binary artifact / 二进制制品包含', nullable: true }
      expose :security_binary_artifact_detail, documentation: { type: 'String', desc: 'Security binary artifact detail / 二进制制品包含详情', nullable: true }
      expose :binary_violation_files, documentation: { type: 'String', desc: 'Binary violation files / 二进制违规文件', nullable: true }
      expose :binary_archive_list, documentation: { type: 'String', desc: 'Binary archive list / 二进制归档列表', nullable: true }
      expose :security_binary_artifact_raw, documentation: { type: 'Object', desc: 'Security binary artifact raw / 二进制制品原始数据', nullable: true }
      expose :security_package_sig, documentation: { type: 'Boolean', desc: 'Security package sig / 软件包签名', nullable: true }
      expose :lifecycle_release_note, documentation: { type: 'Boolean', desc: 'Lifecycle release note / Release Notes', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Release Quality 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class ReleaseQualityModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::ReleaseQualityModelDataItem,
             documentation: { type: 'ReleaseQualityModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
