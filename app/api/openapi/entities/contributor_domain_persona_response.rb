# frozen_string_literal: true
module Openapi
  module Entities

    class ContributorDomainPersonaItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "a0ddde9c5ad5c6956e5a9662cc4859ad1abaf8b1" }
      expose :level, documentation: { type: 'String', desc: 'level', example: "repo" }
      expose :type, documentation: { type: 'String', desc: 'type', example: '' }
      expose :label, documentation: { type: 'String', desc: 'label', example: "https://github.com/oss-compass/compass-web-service" }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: "Domain Persona" }
      expose :activity_observation_contributor_count, documentation: { type: 'Integer', desc: 'activity_observation_contributor_count', example: 0 }
      expose :activity_observation_contribution_per_person, documentation: { type: 'Integer', desc: 'activity_observation_contribution_per_person', example: 0 }
      expose :activity_code_contributor_count, documentation: { type: 'Integer', desc: 'activity_code_contributor_count', example: 0 }
      expose :activity_code_contribution_per_person, documentation: { type: 'Integer', desc: 'activity_code_contribution_per_person', example: 0 }
      expose :activity_issue_contributor_count, documentation: { type: 'Integer', desc: 'activity_issue_contributor_count', example: 0 }
      expose :activity_issue_contribution_per_person, documentation: { type: 'Integer', desc: 'activity_issue_contribution_per_person', example: 0 }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2022-07-18T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-04-01T12:01:36.215941+00:00" }
      expose :score, documentation: { type: 'Integer', desc: 'score', example: 0 }

    end

    class ContributorDomainPersonaResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::ContributorDomainPersonaItem, documentation: { type: 'Entities::ContributorDomainPersonaItem', desc: 'response',
                                                                 param_type: 'body', is_array: true }

    end

  end
end
