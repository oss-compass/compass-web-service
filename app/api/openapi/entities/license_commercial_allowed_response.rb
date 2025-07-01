module Openapi
  module Entities
    class LicenseCommercialAllowedMetricDetail < Grape::Entity
      expose :license_commercial_allowed,
             documentation: {
               type: 'Integer',
               desc: 'Commercial License Status/商业授权许可状态',
               example: 1,
               values: [0, 1]
             }

      expose :license_list,
             documentation: {
               type: 'Array[String]',
               desc: 'Complete License List/完整许可证列表',
               example: ['MIT', 'Apache-2.0'],
               is_array: true
             }

      expose :non_commercial_licenses,
             documentation: {
               type: 'Array[String]',
               desc: 'Non-Commercial License List/非商业许可列表',
               example: ['CC-BY-NC-4.0'],
               is_array: true
             }

      expose :license_commercial_allowed_details,
             documentation: {
               type: 'String',
               desc: 'Commercial License Details/商业授权详情描述',
               example: 'All licenses allow closed source modification'
             }
    end

    class LicenseCommercialAllowedItem < Grape::Entity
      expose :uuid,
             documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :metric_type, documentation: { type: 'String', desc: 'metric_type', example: 'community_portrait' }
      expose :metric_name, documentation: { type: 'String', desc: 'metric_name', example: 'license_commercial_allowed' }
      expose :metric_detail, using: Entities::LicenseCommercialAllowedMetricDetail,
             documentation: { type: 'LicenseCommercialAllowedMetricDetail', desc: 'license_commercial_allowed' }
      expose :version_number, documentation: { type: 'NilClass', desc: 'version_number', example: nil } # 新增字段
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on',
                              example: '2025-05-14T07:28:30.512875+00:00' }
    end

    class LicenseCommercialAllowedResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count/总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages/总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page/当前页', example: 1 }
      expose :items, using: Entities::LicenseCommercialAllowedItem,
             documentation: { type: 'Entities::LicenseCommercialAllowedItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
