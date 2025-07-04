# frozen_string_literal: true
module Openapi
  module Entities

    class IssueItem < Grape::Entity
      expose :metadata__updated_on, documentation: { type: 'String', desc: 'metadata__updated_on', example: "2023-03-06T06:44:41+00:00" }
      expose :metadata__timestamp, documentation: { type: 'String', desc: 'metadata__timestamp', example: "2023-08-04T06:28:28.681850+00:00" }
      expose :offset, documentation: { type: 'String', desc: 'offset', example: ''}
      expose :origin, documentation: { type: 'String', desc: 'origin', example: "https://github.com/oss-compass/compass-web-service" }
      expose :tag, documentation: { type: 'String', desc: 'tag', example: "https://github.com/oss-compass/compass-web-service" }
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "ad2833abc1ca9ccc9dc2ebc1cab44d0a2bcfde3c" }
      expose :time_to_close_days, documentation: { type: 'Integer', desc: 'time_to_close_days', example: 0 }
      expose :time_open_days, documentation: { type: 'Integer', desc: 'time_open_days', example: 0 }
      expose :user_login, documentation: { type: 'String', desc: 'user_login', example: "eyehwan" }
      expose :user_name, documentation: { type: 'String', desc: 'user_name', example: "Yehui Wang" }
      expose :author_name, documentation: { type: 'String', desc: 'author_name', example: "Yehui Wang" }
      expose :user_email, documentation: { type: 'String', desc: 'user_email', example: "yehui.wang.mdh@gmail.com" }
      expose :user_domain, documentation: { type: 'String', desc: 'user_domain', example: "gmail.com" }
      expose :user_org, documentation: { type: 'String', desc: 'user_org', example: ''}
      expose :user_location, documentation: { type: 'String', desc: 'user_location', example: "shanghai, China" }
      expose :user_geolocation, documentation: { type: 'String', desc: 'user_geolocation', example: ''}
      expose :assignee_login, documentation: { type: 'String', desc: 'assignee_login', example: "EdmondFrank" }
      expose :assignee_name, documentation: { type: 'String', desc: 'assignee_name', example: "edmondfrank" }
      expose :assignee_domain, documentation: { type: 'String', desc: 'assignee_domain', example: "Yahoo.com" }
      expose :assignee_org, documentation: { type: 'String', desc: 'assignee_org', example: ''}
      expose :assignee_location, documentation: { type: 'String', desc: 'assignee_location', example: "China" }
      expose :assignee_geolocation, documentation: { type: 'String', desc: 'assignee_geolocation', example: ''}
      expose :id, documentation: { type: 'Integer', desc: 'id', example: 1610677521 }
      expose :id_in_repo, documentation: { type: 'String', desc: 'id_in_repo', example: "3" }
      expose :repository, documentation: { type: 'String', desc: 'repository', example: "https://github.com/oss-compass/compass-web-service" }
      expose :title, documentation: { type: 'String', desc: 'title', example: "Back End: New project submit Checking Rules(提交的项目检测)" }
      expose :title_analyzed, documentation: { type: 'String', desc: 'title_analyzed', example: "Back End: New project submit Checking Rules(提交的项目检测)" }
      expose :state, documentation: { type: 'String', desc: 'state', example: "closed" }
      expose :created_at, documentation: { type: 'String', desc: 'created_at', example: "2023-03-06T05:09:17Z" }
      expose :updated_at, documentation: { type: 'String', desc: 'updated_at', example: "2023-03-06T06:44:41Z" }
      expose :closed_at, documentation: { type: 'String', desc: 'closed_at', example: "2023-03-06T05:09:31Z" }
      expose :url, documentation: { type: 'String', desc: 'url', example: "https://github.com/oss-compass/compass-web-service/issues/3" }
      expose :issue_url, documentation: { type: 'String', desc: 'issue_url', example: "https://github.com/oss-compass/compass-web-service/issues/3" }
      expose :labels, documentation: { type: 'String', desc: 'labels', example: ["enhancement"], is_array: true }
      expose :pull_request, documentation: { type: 'Boolean', desc: 'pull_request', example: false }
      expose :item_type, documentation: { type: 'String', desc: 'item_type', example: "issue" }
      expose :github_repo, documentation: { type: 'String', desc: 'github_repo', example: "oss-compass/compass-web-service" }
      expose :url_id, documentation: { type: 'String', desc: 'url_id', example: "oss-compass/compass-web-service/issues/3" }
      expose :body, documentation: { type: 'String', desc: 'body', example: "    - 需要加License检查,                \r\n    - fork仓需要有检测机制               \r\n    - 重复检测： 如果一个项目已经提交，再次提交的时候，要显示存在的compass地址了" }
      expose :project, documentation: { type: 'String', desc: 'project', example: "github-oss-compass-compass-web-service" }
      expose :project_1, documentation: { type: 'String', desc: 'project_1', example: "github-oss-compass-compass-web-service" }
      expose :time_to_first_attention, documentation: { type: 'String', desc: 'time_to_first_attention', example: ''}
      expose :num_of_comments_without_bot, documentation: { type: 'String', desc: 'num_of_comments_without_bot', example: ''}
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2023-03-06T05:09:17+00:00" }
      expose :is_github_issue, documentation: { type: 'Integer', desc: 'is_github_issue', example: 1 }
      expose :assignee_data_id, documentation: { type: 'String', desc: 'assignee_data_id', example: "394704c1b85fbd92997c3514cae581380947941d" }
      expose :assignee_data_uuid, documentation: { type: 'String', desc: 'assignee_data_uuid', example: "394704c1b85fbd92997c3514cae581380947941d" }
      expose :assignee_data_name, documentation: { type: 'String', desc: 'assignee_data_name', example: "edmondfrank" }
      expose :assignee_data_user_name, documentation: { type: 'String', desc: 'assignee_data_user_name', example: "EdmondFrank" }
      expose :assignee_data_domain, documentation: { type: 'String', desc: 'assignee_data_domain', example: "Yahoo.com" }
      expose :assignee_data_gender, documentation: { type: 'String', desc: 'assignee_data_gender', example: "Unknown" }
      expose :assignee_data_gender_acc, documentation: { type: 'String', desc: 'assignee_data_gender_acc', example: ''}
      expose :assignee_data_org_name, documentation: { type: 'String', desc: 'assignee_data_org_name', example: "Unknown" }
      expose :assignee_data_bot, documentation: { type: 'Boolean', desc: 'assignee_data_bot', example: false }
      expose :assignee_data_multi_org_names, documentation: { type: 'String', desc: 'assignee_data_multi_org_names', example: ["Unknown"], is_array: true }
      expose :user_data_id, documentation: { type: 'String', desc: 'user_data_id', example: "80bf96b533f71b3fddcc7aa3d56c19929240bc35" }
      expose :user_data_uuid, documentation: { type: 'String', desc: 'user_data_uuid', example: "80bf96b533f71b3fddcc7aa3d56c19929240bc35" }
      expose :user_data_name, documentation: { type: 'String', desc: 'user_data_name', example: "Yehui Wang" }
      expose :user_data_user_name, documentation: { type: 'String', desc: 'user_data_user_name', example: "eyehwan" }
      expose :user_data_domain, documentation: { type: 'String', desc: 'user_data_domain', example: "gmail.com" }
      expose :user_data_gender, documentation: { type: 'String', desc: 'user_data_gender', example: "Unknown" }
      expose :user_data_gender_acc, documentation: { type: 'String', desc: 'user_data_gender_acc', example: ''}
      expose :user_data_org_name, documentation: { type: 'String', desc: 'user_data_org_name', example: "Unknown" }
      expose :user_data_bot, documentation: { type: 'Boolean', desc: 'user_data_bot', example: false }
      expose :user_data_multi_org_names, documentation: { type: 'String', desc: 'user_data_multi_org_names', example: ["Unknown"], is_array: true }
      expose :author_id, documentation: { type: 'String', desc: 'author_id', example: "80bf96b533f71b3fddcc7aa3d56c19929240bc35" }
      expose :author_uuid, documentation: { type: 'String', desc: 'author_uuid', example: "80bf96b533f71b3fddcc7aa3d56c19929240bc35" }
      expose :author_user_name, documentation: { type: 'String', desc: 'author_user_name', example: "eyehwan" }
      expose :author_domain, documentation: { type: 'String', desc: 'author_domain', example: "gmail.com" }
      expose :author_gender, documentation: { type: 'String', desc: 'author_gender', example: "Unknown" }
      expose :author_gender_acc, documentation: { type: 'String', desc: 'author_gender_acc', example: ''}
      expose :author_org_name, documentation: { type: 'String', desc: 'author_org_name', example: "Unknown" }
      expose :author_bot, documentation: { type: 'Boolean', desc: 'author_bot', example: false }
      expose :author_multi_org_names, documentation: { type: 'String', desc: 'author_multi_org_names', example: ["Unknown"], is_array: true }
      expose :repository_labels, documentation: { type: 'String', desc: 'repository_labels', example: [], is_array: true }
      expose :metadata__filter_raw, documentation: { type: 'String', desc: 'metadata__filter_raw', example: ''}
      expose :metadata__gelk_version, documentation: { type: 'String', desc: 'metadata__gelk_version', example: "0.103.0-rc.4" }
      expose :metadata__gelk_backend_name, documentation: { type: 'String', desc: 'metadata__gelk_backend_name', example: "GitHubEnrich" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2023-12-31T17:24:51.534244+00:00" }

    end

    class IssueResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::IssueItem, documentation: { type: 'Entities::IssueItem', desc: 'response',
                                                                  param_type: 'body', is_array: true }
    end

  end
end
