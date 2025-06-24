# frozen_string_literal: true
module Openapi
  module Entities

    class CriticalityScoreItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "9497744d49ae8c0eba2b657d55a178a4b12c2b77" }
      expose :level, documentation: { type: 'String', desc: 'level', example: "repo" }
      expose :type, documentation: { type: 'String', desc: 'type', example: '' }
      expose :label, documentation: { type: 'String', desc: 'label', example: "https://github.com/oss-compass/compass-web-service" }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: "Criticality Score" }

      expose :score, documentation: { type: 'Float', desc: 'score of criticality score metric model', example: 1}
      expose :created_since, documentation: { type: 'Float', desc: 'Time since the project was created (in months)', example: 1}
      expose :updated_since, documentation: { type: 'Float', desc: 'Time since the project was last updated (in months)', example: 1}
      expose :contributor_count_all, documentation: { type: 'Float', desc: 'Count of project contributors (with commits)', example: 1}
      expose :org_count_all, documentation: { type: 'Float', desc: 'Count of distinct organizations that contributors belong to', example: 1}
      expose :commit_frequency_last_year, documentation: { type: 'Float', desc: 'Average number of commits per week in the last year', example: 1}
      expose :recent_releases_count, documentation: { type: 'Float', desc: 'Number of releases in the last year', example: 1}
      expose :closed_issues_count, documentation: { type: 'Float', desc: 'Number of issues closed in the last 90 days', example: 1}
      expose :updated_issues_count, documentation: { type: 'Float', desc: 'Number of issues updated in the last 90 days', example: 1}
      expose :comment_frequency, documentation: { type: 'Float', desc: 'Average number of comments per issue in the last 90 days', example: 1}
      expose :dependents_count, documentation: { type: 'Float', desc: 'Number of project mentions in the commit messages', example: 1}

      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2022-07-18T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2024-01-17T22:47:46.075025+00:00" }
    #
    end

    class CriticalityScoreResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::CriticalityScoreItem, documentation: { type: 'Entities::CriticalityScoreItem', desc: 'response',
                                                                 param_type: 'body', is_array: true }

    end

  end
end
