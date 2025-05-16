# frozen_string_literal: true
module Openapi
  module Entities

    class ActivityItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "9497744d49ae8c0eba2b657d55a178a4b12c2b77" }
      expose :level, documentation: { type: 'String', desc: 'level', example: "repo" }
      expose :type, documentation: { type: 'String', desc: 'type', example: '' }
      expose :label, documentation: { type: 'String', desc: 'label', example: "https://github.com/oss-compass/compass-web-service" }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: "Activity" }
      expose :contributor_count, documentation: { type: 'Integer', desc: 'contributor_count', example: 1 }
      expose :contributor_count_bot, documentation: { type: 'Integer', desc: 'contributor_count_bot', example: 0 }
      expose :contributor_count_without_bot, documentation: { type: 'Integer', desc: 'contributor_count_without_bot', example: 1 }
      expose :active_C2_contributor_count, documentation: { type: 'Integer', desc: 'active_C2_contributor_count', example: 1 }
      expose :active_C1_pr_create_contributor, documentation: { type: 'Integer', desc: 'active_C1_pr_create_contributor', example: 0 }
      expose :active_C1_pr_comments_contributor, documentation: { type: 'Integer', desc: 'active_C1_pr_comments_contributor', example: 0 }
      expose :active_C1_issue_create_contributor, documentation: { type: 'Integer', desc: 'active_C1_issue_create_contributor', example: 0 }
      expose :active_C1_issue_comments_contributor, documentation: { type: 'Integer', desc: 'active_C1_issue_comments_contributor', example: 0 }
      expose :commit_frequency, documentation: { type: 'Float', desc: 'commit_frequency', example: 0.07782101167315175 }
      expose :commit_frequency_bot, documentation: { type: 'Integer', desc: 'commit_frequency_bot', example: 0 }
      expose :commit_frequency_without_bot, documentation: { type: 'Float', desc: 'commit_frequency_without_bot', example: 0.07782101167315175 }
      expose :org_count, documentation: { type: 'Integer', desc: 'org_count', example: 0 }
      expose :comment_frequency, documentation: { type: 'String', desc: 'comment_frequency', example: '' }
      expose :code_review_count, documentation: { type: 'String', desc: 'code_review_count', example: '' }
      expose :updated_since, documentation: { type: 'Float', desc: 'updated_since', example: 0.12 }
      expose :closed_issues_count, documentation: { type: 'Integer', desc: 'closed_issues_count', example: 0 }
      expose :updated_issues_count, documentation: { type: 'Integer', desc: 'updated_issues_count', example: 0 }
      expose :recent_releases_count, documentation: { type: 'Integer', desc: 'recent_releases_count', example: 0 }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2022-07-18T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2024-01-17T22:47:46.075025+00:00" }
      expose :activity_score, documentation: { type: 'Float', desc: 'activity_score', example: 0.10004935969506674 }
    #
    end

    class ActivityResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::ActivityItem, documentation: { type: 'Entities::ActivityItem', desc: 'response',
                                                                 param_type: 'body', is_array: true }

    end

  end
end
