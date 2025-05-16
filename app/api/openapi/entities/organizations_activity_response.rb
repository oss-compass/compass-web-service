# frozen_string_literal: true
module Openapi
  module Entities

    class OrganizationsActivityItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "d861468acbd4993c03f2192f8cd6421d4ad0365c" }
      expose :level, documentation: { type: 'String', desc: 'level', example: "repo" }
      expose :type, documentation: { type: 'String', desc: 'type', example: '' }
      expose :label, documentation: { type: 'String', desc: 'label', example: "https://github.com/oss-compass/compass-web-service" }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: "Organizations Activity" }
      expose :org_name, documentation: { type: 'String', desc: 'org_name', example: "hotmail.com" }
      expose :is_org, documentation: { type: 'Boolean', desc: 'is_org', example: false }
      expose :contributor_count, documentation: { type: 'Integer', desc: 'contributor_count', example: 0 }
      expose :contributor_count_bot, documentation: { type: 'Integer', desc: 'contributor_count_bot', example: 0 }
      expose :contributor_count_without_bot, documentation: { type: 'Integer', desc: 'contributor_count_without_bot', example: 0 }
      expose :contributor_org_count, documentation: { type: 'Integer', desc: 'contributor_org_count', example: 1 }
      expose :commit_frequency, documentation: { type: 'Integer', desc: 'commit_frequency', example: 0 }
      expose :commit_frequency_bot, documentation: { type: 'Integer', desc: 'commit_frequency_bot', example: 0 }
      expose :commit_frequency_without_bot, documentation: { type: 'Integer', desc: 'commit_frequency_without_bot', example: 0 }
      expose :commit_frequency_org, documentation: { type: 'Integer', desc: 'commit_frequency_org', example: 1 }
      expose :commit_frequency_org_percentage, documentation: { type: 'Integer', desc: 'commit_frequency_org_percentage', example: 1 }
      expose :commit_frequency_percentage, documentation: { type: 'Integer', desc: 'commit_frequency_percentage', example: 1 }
      expose :org_count, documentation: { type: 'Integer', desc: 'org_count', example: 0 }
      expose :contribution_last, documentation: { type: 'Integer', desc: 'contribution_last', example: 0 }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2022-07-18T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2024-01-17T22:48:13.259894+00:00" }
      expose :organizations_activity, documentation: { type: 'Integer', desc: 'organizations_activity', example: 0 }

    end

    class OrganizationsActivityResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::OrganizationsActivityItem, documentation: { type: 'Entities::OrganizationsActivityItem', desc: 'response',
                                                                 param_type: 'body', is_array: true }

    end

  end
end
