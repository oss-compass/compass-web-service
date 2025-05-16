# frozen_string_literal: true
module Openapi
  module Entities

    class ContributorMilestonePersonaItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "796e1a65e927b1b64652671cb6607b87a74738d1" }
      expose :level, documentation: { type: 'String', desc: 'level', example: "repo" }
      expose :type, documentation: { type: 'String', desc: 'type', example: '' }
      expose :label, documentation: { type: 'String', desc: 'label', example: "https://github.com/oss-compass/compass-web-service" }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: "Milestone Persona" }
      expose :activity_casual_contributor_count, documentation: { type: 'Integer', desc: 'activity_casual_contributor_count', example: 0 }
      expose :activity_casual_contribution_per_person, documentation: { type: 'Integer', desc: 'activity_casual_contribution_per_person', example: 0 }
      expose :activity_regular_contributor_count, documentation: { type: 'Integer', desc: 'activity_regular_contributor_count', example: 0 }
      expose :activity_regular_contribution_per_person, documentation: { type: 'Integer', desc: 'activity_regular_contribution_per_person', example: 0 }
      expose :activity_core_contributor_count, documentation: { type: 'Integer', desc: 'activity_core_contributor_count', example: 0 }
      expose :activity_core_contribution_per_person, documentation: { type: 'Integer', desc: 'activity_core_contribution_per_person', example: 0 }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2022-07-18T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-04-01T12:02:25.058952+00:00" }
      expose :score, documentation: { type: 'Integer', desc: 'score', example: 0 }

    end

    class ContributorMilestonePersonaResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::ContributorMilestonePersonaItem, documentation: { type: 'Entities::ContributorMilestonePersonaItem', desc: 'response',
                                                                 param_type: 'body', is_array: true }

    end

  end
end
