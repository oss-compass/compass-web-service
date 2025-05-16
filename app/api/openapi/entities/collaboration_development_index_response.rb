# frozen_string_literal: true
module Openapi
  module Entities

    class CollaborationDevelopmentIndexItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "e687b01abc5ffd9a0bbf0fed75b5d8a65ff9b561" }
      expose :level, documentation: { type: 'String', desc: 'level', example: "repo" }
      expose :type, documentation: { type: 'String', desc: 'type', example: '' }
      expose :label, documentation: { type: 'String', desc: 'label', example: "https://github.com/oss-compass/compass-web-service" }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: "Code_Quality_Guarantee" }
      expose :contributor_count, documentation: { type: 'Integer', desc: 'contributor_count', example: 1 }
      expose :contributor_count_bot, documentation: { type: 'Integer', desc: 'contributor_count_bot', example: 0 }
      expose :contributor_count_without_bot, documentation: { type: 'Integer', desc: 'contributor_count_without_bot', example: 1 }
      expose :active_C2_contributor_count, documentation: { type: 'Integer', desc: 'active_C2_contributor_count', example: 1 }
      expose :active_C1_pr_create_contributor, documentation: { type: 'Integer', desc: 'active_C1_pr_create_contributor', example: 0 }
      expose :active_C1_pr_comments_contributor, documentation: { type: 'Integer', desc: 'active_C1_pr_comments_contributor', example: 0 }
      expose :commit_frequency, documentation: { type: 'Float', desc: 'commit_frequency', example: 0.07782101167315175 }
      expose :commit_frequency_bot, documentation: { type: 'Integer', desc: 'commit_frequency_bot', example: 0 }
      expose :commit_frequency_without_bot, documentation: { type: 'Float', desc: 'commit_frequency_without_bot', example: 0.07782101167315175 }
      expose :commit_frequency_inside, documentation: { type: 'Integer', desc: 'commit_frequency_inside', example: 0 }
      expose :commit_frequency_inside_bot, documentation: { type: 'Integer', desc: 'commit_frequency_inside_bot', example: 0 }
      expose :commit_frequency_inside_without_bot, documentation: { type: 'Integer', desc: 'commit_frequency_inside_without_bot', example: 0 }
      expose :is_maintained, documentation: { type: 'Integer', desc: 'is_maintained', example: 0 }
      expose :LOC_frequency, documentation: { type: 'Float', desc: 'LOC_frequency', example: 562.9571984435797 }
      expose :lines_added_frequency, documentation: { type: 'Float', desc: 'lines_added_frequency', example: 562.9571984435797 }
      expose :lines_removed_frequency, documentation: { type: 'Integer', desc: 'lines_removed_frequency', example: 0 }
      expose :pr_issue_linked_ratio, documentation: { type: 'String', desc: 'pr_issue_linked_ratio', example: '' }
      expose :code_review_ratio, documentation: { type: 'String', desc: 'code_review_ratio', example: '' }
      expose :code_merge_ratio, documentation: { type: 'String', desc: 'code_merge_ratio', example: '' }
      expose :pr_count, documentation: { type: 'Integer', desc: 'pr_count', example: 0 }
      expose :pr_merged_count, documentation: { type: 'Integer', desc: 'pr_merged_count', example: 0 }
      expose :pr_commit_count, documentation: { type: 'Integer', desc: 'pr_commit_count', example: 1 }
      expose :pr_commit_linked_count, documentation: { type: 'Integer', desc: 'pr_commit_linked_count', example: 0 }
      expose :git_pr_linked_ratio, documentation: { type: 'Integer', desc: 'git_pr_linked_ratio', example: 0 }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2022-07-18T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2024-01-17T22:48:12.417052+00:00" }
      expose :code_quality_guarantee, documentation: { type: 'Float', desc: 'code_quality_guarantee', example: 0.05017 }

    end

    class CollaborationDevelopmentIndexResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::CollaborationDevelopmentIndexItem, documentation: { type: 'Entities::CollaborationDevelopmentIndexItem', desc: 'response',
                                                                 param_type: 'body', is_array: true }

    end

  end
end
