# frozen_string_literal: true
module Openapi
  module Entities

    class EventItem < Grape::Entity
      expose :metadata__updated_on, documentation: { type: 'String', desc: 'metadata__updated_on', example: "2023-01-14T10:58:03+00:00" }
      expose :metadata__timestamp, documentation: { type: 'String', desc: 'metadata__timestamp', example: "2023-12-18T17:41:10.771809+00:00" }
      expose :offset, documentation: { type: 'String', desc: 'offset', example: ''}
      expose :origin, documentation: { type: 'String', desc: 'origin', example: "https://gitee.com/easyexcel/easyexcel" }
      expose :tag, documentation: { type: 'String', desc: 'tag', example: "https://gitee.com/easyexcel/easyexcel" }
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "d5004eeb2c12a75e8b6ebd02346fddffa48facad" }
      expose :id, documentation: { type: 'Integer', desc: 'id', example: 101732523 }
      expose :icon, documentation: { type: 'String', desc: 'icon', example: "add square icon" }
      expose :actor_username, documentation: { type: 'String', desc: 'actor_username', example: "zhuangjiaju" }
      expose :user_login, documentation: { type: 'String', desc: 'user_login', example: "zhuangjiaju" }
      expose :content, documentation: { type: 'String', desc: 'content', example: "Created Task/创建了任务" }
      expose :created_at, documentation: { type: 'String', desc: 'created_at', example: "2023-01-14T18:58:03+08:00" }
      expose :action_type, documentation: { type: 'String', desc: 'action_type', example: "create" }
      expose :event_type, documentation: { type: 'String', desc: 'event_type', example: "CreateEvent" }
      expose :repository, documentation: { type: 'String', desc: 'repository', example: "https://gitee.com/easyexcel/easyexcel" }
      expose :pull_request, documentation: { type: 'Boolean', desc: 'pull_request', example: false }
      expose :item_type, documentation: { type: 'String', desc: 'item_type', example: "issue" }
      expose :gitee_repo, documentation: { type: 'String', desc: 'gitee_repo', example: "easyexcel/easyexcel" }
      expose :issue_id, documentation: { type: 'Integer', desc: 'issue_id', example: 10570273 }
      expose :issue_id_in_repo, documentation: { type: 'String', desc: 'issue_id_in_repo', example: "I6AK2P" }
      expose :issue_title, documentation: { type: 'String', desc: 'issue_title', example: "Order" }
      expose :issue_title_analyzed, documentation: { type: 'String', desc: 'issue_title_analyzed', example: "Order" }
      expose :issue_state, documentation: { type: 'String', desc: 'issue_state', example: "closed" }
      expose :issue_created_at, documentation: { type: 'String', desc: 'issue_created_at', example: "2023-01-14T18:58:03+08:00" }
      expose :issue_updated_at, documentation: { type: 'String', desc: 'issue_updated_at', example: "2023-01-14T18:58:55+08:00" }
      expose :issue_closed_at, documentation: { type: 'String', desc: 'issue_closed_at', example: "2023-01-14T18:58:55+08:00" }
      expose :issue_finished_at, documentation: { type: 'String', desc: 'issue_finished_at', example: "2023-01-14T18:58:55+08:00" }
      expose :issue_url, documentation: { type: 'String', desc: 'issue_url', example: "https://gitee.com/easyexcel/easyexcel/issues/I6AK2P" }
      expose :issue_labels, documentation: { type: 'String', desc: 'issue_labels', example: [], is_array: true }
      expose :issue_url_id, documentation: { type: 'String', desc: 'issue_url_id', example: "easyexcel/easyexcel/issues/I6AK2P" }
      expose :project, documentation: { type: 'String', desc: 'project', example: "gitee-easyexcel-easyexcel" }
      expose :project_1, documentation: { type: 'String', desc: 'project_1', example: "gitee-easyexcel-easyexcel" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2023-01-14T18:58:03+08:00" }
      expose :is_gitee_event, documentation: { type: 'Integer', desc: 'is_gitee_event', example: 1 }
      expose :actor_id, documentation: { type: 'String', desc: 'actor_id', example: "1f63e05cebedf3720687e9d432b6b9ab3bce9d82" }
      expose :actor_uuid, documentation: { type: 'String', desc: 'actor_uuid', example: "1f63e05cebedf3720687e9d432b6b9ab3bce9d82" }
      expose :actor_name, documentation: { type: 'String', desc: 'actor_name', example: "Zhuang Jiaju" }
      expose :actor_user_name, documentation: { type: 'String', desc: 'actor_user_name', example: "zhuangjiaju" }
      expose :actor_domain, documentation: { type: 'String', desc: 'actor_domain', example: ''}
      expose :actor_gender, documentation: { type: 'String', desc: 'actor_gender', example: "Unknown" }
      expose :actor_gender_acc, documentation: { type: 'String', desc: 'actor_gender_acc', example: ''}
      expose :actor_org_name, documentation: { type: 'String', desc: 'actor_org_name', example: "Unknown" }
      expose :actor_bot, documentation: { type: 'Boolean', desc: 'actor_bot', example: false }
      expose :actor_multi_org_names, documentation: { type: 'String', desc: 'actor_multi_org_names', example: ["Unknown"], is_array: true }
      expose :reporter_id, documentation: { type: 'String', desc: 'reporter_id', example: "1f63e05cebedf3720687e9d432b6b9ab3bce9d82" }
      expose :reporter_uuid, documentation: { type: 'String', desc: 'reporter_uuid', example: "1f63e05cebedf3720687e9d432b6b9ab3bce9d82" }
      expose :reporter_name, documentation: { type: 'String', desc: 'reporter_name', example: "Zhuang Jiaju" }
      expose :reporter_user_name, documentation: { type: 'String', desc: 'reporter_user_name', example: "zhuangjiaju" }
      expose :reporter_domain, documentation: { type: 'String', desc: 'reporter_domain', example: ''}
      expose :reporter_gender, documentation: { type: 'String', desc: 'reporter_gender', example: "Unknown" }
      expose :reporter_gender_acc, documentation: { type: 'String', desc: 'reporter_gender_acc', example: ''}
      expose :reporter_org_name, documentation: { type: 'String', desc: 'reporter_org_name', example: "Unknown" }
      expose :reporter_bot, documentation: { type: 'Boolean', desc: 'reporter_bot', example: false }
      expose :reporter_multi_org_names, documentation: { type: 'String', desc: 'reporter_multi_org_names', example: ["Unknown"], is_array: true }
      expose :repository_labels, documentation: { type: 'String', desc: 'repository_labels', example: [], is_array: true }
      expose :metadata__filter_raw, documentation: { type: 'String', desc: 'metadata__filter_raw', example: ''}
      expose :metadata__gelk_version, documentation: { type: 'String', desc: 'metadata__gelk_version', example: "0.103.0-rc.4" }
      expose :metadata__gelk_backend_name, documentation: { type: 'String', desc: 'metadata__gelk_backend_name', example: "GiteeEnrich" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2023-12-18T17:45:07.832159+00:00" }

    end

    class EventResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count/总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages/总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page/当前页', example: 1 }
      expose :items, using: Entities::EventItem, documentation: { type: 'Entities::EventItem', desc: 'response',
                                                                  param_type: 'body', is_array: true }
    end

  end
end
