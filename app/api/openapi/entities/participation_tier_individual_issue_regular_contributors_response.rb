# frozen_string_literal: true

module Openapi
  module Entities
    class ParticipationTierIndividualIssueRegularContributorsItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :individual_issue_regular_contributors,
             documentation: {
               type: 'Integer',
               desc: 'Individual Issue regular contributors / 个人Issue常客开发者数量',
               example: 1,
               minimum: 0,
               nullable: true
             }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    class ParticipationTierIndividualIssueRegularContributorsResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数' }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数' }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页' }
      expose :items, using: Entities::ParticipationTierIndividualIssueRegularContributorsItem,
             documentation: { type: 'ParticipationTierIndividualIssueRegularContributorsItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
