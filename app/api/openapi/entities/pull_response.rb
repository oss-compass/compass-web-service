# frozen_string_literal: true
module Openapi
  module Entities

    class PullItem < Grape::Entity
      expose :metadata__updated_on, documentation: { type: 'String', desc: 'metadata__updated_on', example: "2023-05-24T02:21:57+00:00" }
      expose :metadata__timestamp, documentation: { type: 'String', desc: 'metadata__timestamp', example: "2025-01-22T03:22:49.854525+00:00" }
      expose :offset, documentation: { type: 'String', desc: 'offset', example: '' }
      expose :origin, documentation: { type: 'String', desc: 'origin', example: "https://github.com/oss-compass/compass-web-service" }
      expose :tag, documentation: { type: 'String', desc: 'tag', example: "https://github.com/oss-compass/compass-web-service" }
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "a72c2b7b8b700b0105981fd3c49f951d15e70a9d" }
      expose :time_to_close_days, documentation: { type: 'Float', desc: 'time_to_close_days', example: 41.84 }
      expose :time_open_days, documentation: { type: 'Float', desc: 'time_open_days', example: 41.84 }
      expose :user_login, documentation: { type: 'String', desc: 'user_login', example: "dependabot[bot]" }
      expose :user_name, documentation: { type: 'String', desc: 'user_name', example: '' }
      expose :author_name, documentation: { type: 'String', desc: 'author_name', example: "Unknown" }
      expose :user_domain, documentation: { type: 'String', desc: 'user_domain', example: '' }
      expose :user_org, documentation: { type: 'String', desc: 'user_org', example: '' }
      expose :user_location, documentation: { type: 'String', desc: 'user_location', example: '' }
      expose :user_geolocation, documentation: { type: 'String', desc: 'user_geolocation', example: '' }
      expose :merge_author_login, documentation: { type: 'String', desc: 'merge_author_login', example: "EdmondFrank" }
      expose :merge_author_name, documentation: { type: 'String', desc: 'merge_author_name', example: "edmondfrank" }
      expose :merge_author_domain, documentation: { type: 'String', desc: 'merge_author_domain', example: "hotmail.com" }
      expose :merge_author_org, documentation: { type: 'String', desc: 'merge_author_org', example: '' }
      expose :merge_author_location, documentation: { type: 'String', desc: 'merge_author_location', example: "China" }
      expose :merge_author_geolocation, documentation: { type: 'String', desc: 'merge_author_geolocation', example: '' }
      expose :id, documentation: { type: 'Integer', desc: 'id', example: 1310291728 }
      expose :id_in_repo, documentation: { type: 'String', desc: 'id_in_repo', example: "17" }
      expose :repository, documentation: { type: 'String', desc: 'repository', example: "https://github.com/oss-compass/compass-web-service" }
      expose :title, documentation: { type: 'String', desc: 'title', example: "Bump nokogiri from 1.13.8 to 1.14.3" }
      expose :title_analyzed, documentation: { type: 'String', desc: 'title_analyzed', example: "Bump nokogiri from 1.13.8 to 1.14.3" }
      expose :state, documentation: { type: 'String', desc: 'state', example: "closed" }
      expose :created_at, documentation: { type: 'String', desc: 'created_at', example: "2023-04-12T06:18:01Z" }
      expose :updated_at, documentation: { type: 'String', desc: 'updated_at', example: "2023-05-24T02:21:57Z" }
      expose :merged, documentation: { type: 'Boolean', desc: 'merged', example: true }
      expose :merged_at, documentation: { type: 'String', desc: 'merged_at', example: "2023-05-24T02:21:49Z" }
      expose :closed_at, documentation: { type: 'String', desc: 'closed_at', example: "2023-05-24T02:21:49Z" }
      expose :url, documentation: { type: 'String', desc: 'url', example: "https://github.com/oss-compass/compass-web-service/pull/17" }
      expose :additions, documentation: { type: 'Integer', desc: 'additions', example: 3 }
      expose :deletions, documentation: { type: 'Integer', desc: 'deletions', example: 3 }
      expose :changed_files, documentation: { type: 'Integer', desc: 'changed_files', example: 1 }
      expose :issue_url, documentation: { type: 'String', desc: 'issue_url', example: "https://github.com/oss-compass/compass-web-service/pull/17" }
      expose :labels, documentation: { type: 'String', desc: 'labels', example: ["dependencies"], is_array: true }
      expose :pull_request, documentation: { type: 'Boolean', desc: 'pull_request', example: true }
      expose :item_type, documentation: { type: 'String', desc: 'item_type', example: "pull request" }
      expose :github_repo, documentation: { type: 'String', desc: 'github_repo', example: "oss-compass/compass-web-service" }
      expose :url_id, documentation: { type: 'String', desc: 'url_id', example: "oss-compass/compass-web-service/pull/17" }
      expose :forks, documentation: { type: 'Integer', desc: 'forks', example: 4 }
      expose :code_merge_duration, documentation: { type: 'Float', desc: 'code_merge_duration', example: 41.84 }
      expose :num_review_comments, documentation: { type: 'Integer', desc: 'num_review_comments', example: 0 }
      expose :time_to_merge_request_response, documentation: { type: 'String', desc: 'time_to_merge_request_response', example: '' }
      expose :project, documentation: { type: 'String', desc: 'project', example: "Github-compass-web-service" }
      expose :project_1, documentation: { type: 'String', desc: 'project_1', example: "Github-compass-web-service" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2023-04-12T06:18:01+00:00" }
      expose :is_github_pull_request, documentation: { type: 'Integer', desc: 'is_github_pull_request', example: 1 }
      expose :merged_by_data_id, documentation: { type: 'String', desc: 'merged_by_data_id', example: "b37d47dd66f6a4bf1d2f764a51cfa64e0545315f" }
      expose :merged_by_data_uuid, documentation: { type: 'String', desc: 'merged_by_data_uuid', example: "b37d47dd66f6a4bf1d2f764a51cfa64e0545315f" }
      expose :merged_by_data_name, documentation: { type: 'String', desc: 'merged_by_data_name', example: "edmondfrank" }
      expose :merged_by_data_user_name, documentation: { type: 'String', desc: 'merged_by_data_user_name', example: "EdmondFrank" }
      expose :merged_by_data_domain, documentation: { type: 'String', desc: 'merged_by_data_domain', example: "hotmail.com" }
      expose :merged_by_data_gender, documentation: { type: 'String', desc: 'merged_by_data_gender', example: "Unknown" }
      expose :merged_by_data_gender_acc, documentation: { type: 'String', desc: 'merged_by_data_gender_acc', example: '' }
      expose :merged_by_data_org_name, documentation: { type: 'String', desc: 'merged_by_data_org_name', example: "Unknown" }
      expose :merged_by_data_bot, documentation: { type: 'Boolean', desc: 'merged_by_data_bot', example: false }
      expose :merged_by_data_multi_org_names, documentation: { type: 'String', desc: 'merged_by_data_multi_org_names', example: ["Unknown"], is_array: true }
      expose :user_data_id, documentation: { type: 'String', desc: 'user_data_id', example: "78a1a84979357c6dd727e5c4b6a12832a7f5500f" }
      expose :user_data_uuid, documentation: { type: 'String', desc: 'user_data_uuid', example: "78a1a84979357c6dd727e5c4b6a12832a7f5500f" }
      expose :user_data_name, documentation: { type: 'String', desc: 'user_data_name', example: "Unknown" }
      expose :user_data_user_name, documentation: { type: 'String', desc: 'user_data_user_name', example: "dependabot[bot]" }
      expose :user_data_domain, documentation: { type: 'String', desc: 'user_data_domain', example: '' }
      expose :user_data_gender, documentation: { type: 'String', desc: 'user_data_gender', example: "Unknown" }
      expose :user_data_gender_acc, documentation: { type: 'String', desc: 'user_data_gender_acc', example: '' }
      expose :user_data_org_name, documentation: { type: 'String', desc: 'user_data_org_name', example: "Unknown" }
      expose :user_data_bot, documentation: { type: 'Boolean', desc: 'user_data_bot', example: false }
      expose :user_data_multi_org_names, documentation: { type: 'String', desc: 'user_data_multi_org_names', example: ["Unknown"], is_array: true }
      expose :author_id, documentation: { type: 'String', desc: 'author_id', example: "78a1a84979357c6dd727e5c4b6a12832a7f5500f" }
      expose :author_uuid, documentation: { type: 'String', desc: 'author_uuid', example: "78a1a84979357c6dd727e5c4b6a12832a7f5500f" }
      expose :author_user_name, documentation: { type: 'String', desc: 'author_user_name', example: "dependabot[bot]" }
      expose :author_domain, documentation: { type: 'String', desc: 'author_domain', example: '' }
      expose :author_gender, documentation: { type: 'String', desc: 'author_gender', example: "Unknown" }
      expose :author_gender_acc, documentation: { type: 'String', desc: 'author_gender_acc', example: '' }
      expose :author_org_name, documentation: { type: 'String', desc: 'author_org_name', example: "Unknown" }
      expose :author_bot, documentation: { type: 'Boolean', desc: 'author_bot', example: false }
      expose :author_multi_org_names, documentation: { type: 'String', desc: 'author_multi_org_names', example: ["Unknown"], is_array: true }
      expose :repository_labels, documentation: { type: 'String', desc: 'repository_labels', example: [], is_array: true }
      expose :metadata__filter_raw, documentation: { type: 'String', desc: 'metadata__filter_raw', example: '' }
      expose :metadata__gelk_version, documentation: { type: 'String', desc: 'metadata__gelk_version', example: "0.103.0-rc.2" }
      expose :metadata__gelk_backend_name, documentation: { type: 'String', desc: 'metadata__gelk_backend_name', example: "GitHubEnrich" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T03:27:03.506703+00:00" }

    end

    class PullResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::PullItem, documentation: { type: 'Entities::PullItem', desc: 'response',
                                                                 param_type: 'body', is_array: true }
    end

  end
end
