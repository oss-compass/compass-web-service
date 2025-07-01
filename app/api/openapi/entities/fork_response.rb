# frozen_string_literal: true
module Openapi
  module Entities

    class ForkItem < Grape::Entity
      expose :metadata__updated_on, documentation: { type: 'String', desc: 'metadata__updated_on', example: "2023-01-18T04:58:31+00:00" }
      expose :metadata__timestamp, documentation: { type: 'String', desc: 'metadata__timestamp', example: "2025-04-16T10:57:32.452055+00:00" }
      expose :offset, documentation: { type: 'String', desc: 'offset', example: ''}
      expose :origin, documentation: { type: 'String', desc: 'origin', example: "https://gitee.com/easyexcel/easyexcel" }
      expose :tag, documentation: { type: 'String', desc: 'tag', example: "https://gitee.com/easyexcel/easyexcel" }
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "7cbdbc05352d65f126c09b05aad67c11caefc300" }
      expose :user_id, documentation: { type: 'Integer', desc: 'user_id', example: 2295886 }
      expose :user_login, documentation: { type: 'String', desc: 'user_login', example: "GatesChe" }
      expose :user_name, documentation: { type: 'String', desc: 'user_name', example: "GatesChe" }
      expose :auhtor_name, documentation: { type: 'String', desc: 'auhtor_name', example: "GatesChe" }
      expose :user_html_url, documentation: { type: 'String', desc: 'user_html_url', example: "https://gitee.com/GatesChe" }
      expose :user_email, documentation: { type: 'String', desc: 'user_email', example: ''}
      expose :user_company, documentation: { type: 'String', desc: 'user_company', example: ''}
      expose :user_remark, documentation: { type: 'String', desc: 'user_remark', example: "" }
      expose :user_type, documentation: { type: 'String', desc: 'user_type', example: "User" }
      expose :fork_at, documentation: { type: 'String', desc: 'fork_at', example: "2023-01-18T12:58:31+08:00" }
      expose :created_at, documentation: { type: 'String', desc: 'created_at', example: "2023-01-18T12:58:31+08:00" }
      expose :project, documentation: { type: 'String', desc: 'project', example: "gitee-easyexcel-easyexcel" }
      expose :project_1, documentation: { type: 'String', desc: 'project_1', example: "gitee-easyexcel-easyexcel" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2023-01-18T12:58:31+08:00" }
      expose :is_gitee_fork, documentation: { type: 'Integer', desc: 'is_gitee_fork', example: 1 }
      expose :repository_labels, documentation: { type: 'String', desc: 'repository_labels', example: [], is_array: true }
      expose :metadata__filter_raw, documentation: { type: 'String', desc: 'metadata__filter_raw', example: ''}
      expose :metadata__gelk_version, documentation: { type: 'String', desc: 'metadata__gelk_version', example: "0.103.0-rc.4" }
      expose :metadata__gelk_backend_name, documentation: { type: 'String', desc: 'metadata__gelk_backend_name', example: "GiteeEnrich" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-04-21T22:09:38.864893+00:00" }

    end

    class ForkResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count/总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages/总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page/当前页', example: 1 }
      expose :items, using: Entities::ForkItem, documentation: { type: 'Entities::ForkItem', desc: 'response',
                                                                 param_type: 'body', is_array: true }
    end

  end
end
