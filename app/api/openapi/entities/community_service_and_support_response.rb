# frozen_string_literal: true
module Openapi
  module Entities

    class CommunityServiceAndSupportItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "d62d94488f401ee7d987d214482d03a8dc69304c" }
      expose :level, documentation: { type: 'String', desc: 'level', example: "repo" }
      expose :type, documentation: { type: 'String', desc: 'type', example: '' }
      expose :label, documentation: { type: 'String', desc: 'label', example: "https://github.com/oss-compass/compass-web-service" }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: "Community Support and Service" }
      expose :issue_first_reponse_avg, documentation: { type: 'String', desc: 'issue_first_reponse_avg', example: '' }
      expose :issue_first_reponse_mid, documentation: { type: 'String', desc: 'issue_first_reponse_mid', example: '' }
      expose :issue_open_time_avg, documentation: { type: 'String', desc: 'issue_open_time_avg', example: '' }
      expose :issue_open_time_mid, documentation: { type: 'String', desc: 'issue_open_time_mid', example: '' }
      expose :bug_issue_open_time_avg, documentation: { type: 'String', desc: 'bug_issue_open_time_avg', example: '' }
      expose :bug_issue_open_time_mid, documentation: { type: 'String', desc: 'bug_issue_open_time_mid', example: '' }
      expose :pr_open_time_avg, documentation: { type: 'String', desc: 'pr_open_time_avg', example: '' }
      expose :pr_open_time_mid, documentation: { type: 'String', desc: 'pr_open_time_mid', example: '' }
      expose :pr_first_response_time_avg, documentation: { type: 'String', desc: 'pr_first_response_time_avg', example: '' }
      expose :pr_first_response_time_mid, documentation: { type: 'String', desc: 'pr_first_response_time_mid', example: '' }
      expose :comment_frequency, documentation: { type: 'String', desc: 'comment_frequency', example: '' }
      expose :code_review_count, documentation: { type: 'String', desc: 'code_review_count', example: '' }
      expose :updated_issues_count, documentation: { type: 'Integer', desc: 'updated_issues_count', example: 0 }
      expose :closed_prs_count, documentation: { type: 'Integer', desc: 'closed_prs_count', example: 0 }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2022-07-18T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2023-08-04T06:51:52.678637+00:00" }
      expose :community_support_score, documentation: { type: 'Integer', desc: 'community_support_score', example: 0 }

    end

    class CommunityServiceAndSupportResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::CommunityServiceAndSupportItem, documentation: { type: 'Entities::CommunityServiceAndSupportItem', desc: 'response',
                                                                                       param_type: 'body', is_array: true }

    end

  end
end
