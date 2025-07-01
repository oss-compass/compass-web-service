# frozen_string_literal: true
module Openapi
  module Entities

    class RepoItem < Grape::Entity
      expose :metadata__updated_on, documentation: { type: 'String', desc: 'metadata__updated_on', example: "2024-04-26T07:08:10.178814+00:00" }
      expose :metadata__timestamp, documentation: { type: 'String', desc: 'metadata__timestamp', example: "2024-04-26T07:08:10.178824+00:00" }
      expose :offset, documentation: { type: 'String', desc: 'offset', example: '' }
      expose :origin, documentation: { type: 'String', desc: 'origin', example: "https://github.com/sidorares/json-bigint" }
      expose :tag, documentation: { type: 'String', desc: 'tag', example: "https://github.com/sidorares/json-bigint" }
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "50e44c1b98749e032f6308b74b41537795d109a1" }
      expose :forks_count, documentation: { type: 'Integer', desc: 'forks_count', example: 189 }
      expose :subscribers_count, documentation: { type: 'Integer', desc: 'subscribers_count', example: 17 }
      expose :stargazers_count, documentation: { type: 'Integer', desc: 'stargazers_count', example: 781 }
      expose :fetched_on, documentation: { type: 'Float', desc: 'fetched_on', example: 1714115290.178814 }
      expose :url, documentation: { type: 'String', desc: 'url', example: "https://github.com/sidorares/json-bigint" }
      expose :archived, documentation: { type: 'Boolean', desc: 'archived', example: false }
      expose :archivedAt, documentation: { type: 'String', desc: 'archivedAt', example: '' }
      expose :created_at, documentation: { type: 'String', desc: 'created_at', example: "2013-09-12T04:31:47Z" }
      expose :updated_at, documentation: { type: 'String', desc: 'updated_at', example: "2024-04-26T04:00:20Z" }
      expose :releases, documentation: { type: 'String', desc: 'releases', example: [], is_array: true }
      expose :releases_count, documentation: { type: 'Integer', desc: 'releases_count', example: 0 }
      expose :topics, documentation: { type: 'String', desc: 'topics', example: [], is_array: true }
      expose :project, documentation: { type: 'String', desc: 'project', example: "github-sidorares-json-bigint" }
      expose :project_1, documentation: { type: 'String', desc: 'project_1', example: "github-sidorares-json-bigint" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2024-04-26T07:08:10.178814+00:00" }
      expose :is_github_repository, documentation: { type: 'Integer', desc: 'is_github_repository', example: 1 }
      expose :repository_labels, documentation: { type: 'String', desc: 'repository_labels', example: [], is_array: true }
      expose :metadata__filter_raw, documentation: { type: 'String', desc: 'metadata__filter_raw', example: '' }
      expose :metadata__gelk_version, documentation: { type: 'String', desc: 'metadata__gelk_version', example: "0.103.0-rc.4" }
      expose :metadata__gelk_backend_name, documentation: { type: 'String', desc: 'metadata__gelk_backend_name', example: "GitHubEnrich" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2024-07-05T01:49:50.011857+00:00" }

    end

    class RepoResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count/总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages/总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page/当前页', example: 1 }
      expose :items, using: Entities::RepoItem, documentation: { type: 'Entities::RepoItem', desc: 'response',
                                                                 param_type: 'body', is_array: true }
    end

  end
end
