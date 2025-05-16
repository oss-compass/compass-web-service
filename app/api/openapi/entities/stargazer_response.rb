# frozen_string_literal: true
module Openapi
  module Entities

    class StargazerItem < Grape::Entity
      expose :metadata__updated_on, documentation: { type: 'String', desc: 'metadata__updated_on', example: "2023-01-14T11:12:50+00:00" }
      expose :metadata__timestamp, documentation: { type: 'String', desc: 'metadata__timestamp', example: "2025-04-16T10:56:58.902014+00:00" }
      expose :offset, documentation: { type: 'String', desc: 'offset', example: '' }
      expose :origin, documentation: { type: 'String', desc: 'origin', example: "https://gitee.com/easyexcel/easyexcel" }
      expose :tag, documentation: { type: 'String', desc: 'tag', example: "https://gitee.com/easyexcel/easyexcel" }
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "d526ebbec02296a9727378d31879c1b83ff260f4" }
      expose :user_id, documentation: { type: 'Integer', desc: 'user_id', example: 374529 }
      expose :user_login, documentation: { type: 'String', desc: 'user_login', example: "zhuangjiaju" }
      expose :user_name, documentation: { type: 'String', desc: 'user_name', example: "庄家钜" }
      expose :auhtor_name, documentation: { type: 'String', desc: 'auhtor_name', example: "庄家钜" }
      expose :user_html_url, documentation: { type: 'String', desc: 'user_html_url', example: "https://gitee.com/zhuangjiaju" }
      expose :user_email, documentation: { type: 'String', desc: 'user_email', example: '' }
      expose :user_company, documentation: { type: 'String', desc: 'user_company', example: '' }
      expose :user_remark, documentation: { type: 'String', desc: 'user_remark', example: "" }
      expose :user_type, documentation: { type: 'String', desc: 'user_type', example: "User" }
      expose :star_at, documentation: { type: 'String', desc: 'star_at', example: "2023-01-14T19:12:50+08:00" }
      expose :created_at, documentation: { type: 'String', desc: 'created_at', example: "2023-01-14T19:12:50+08:00" }
      expose :project, documentation: { type: 'String', desc: 'project', example: "gitee-easyexcel-easyexcel" }
      expose :project_1, documentation: { type: 'String', desc: 'project_1', example: "gitee-easyexcel-easyexcel" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2023-01-14T19:12:50+08:00" }
      expose :is_gitee_stargazer, documentation: { type: 'Integer', desc: 'is_gitee_stargazer', example: 1 }
      expose :repository_labels, documentation: { type: 'String', desc: 'repository_labels', example: [], is_array: true }
      expose :metadata__filter_raw, documentation: { type: 'String', desc: 'metadata__filter_raw', example: '' }
      expose :metadata__gelk_version, documentation: { type: 'String', desc: 'metadata__gelk_version', example: "0.103.0-rc.4" }
      expose :metadata__gelk_backend_name, documentation: { type: 'String', desc: 'metadata__gelk_backend_name', example: "GiteeEnrich" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-04-21T22:09:09.992643+00:00" }

    end

    class StargazerResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::StargazerItem, documentation: { type: 'Entities::StargazerItem', desc: 'response',
                                                                 param_type: 'body', is_array: true }
    end

  end
end
