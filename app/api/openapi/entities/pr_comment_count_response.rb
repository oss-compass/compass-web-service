# frozen_string_literal: true

module Openapi
  module Entities


    class PrCommentCountItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: 'b2495fcb8eac6407bb802a568b55cfcfd9d27f55' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/oss-compass/compass-web-service' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-11-04T00:00:00+00:00' }
      expose :metadata__enriched_on,
             documentation: { type: 'String', desc: 'metadata__enriched_on', example: '2025-05-14T07:28:30.512875+00:00' }

      expose :pr_comment_count,
             documentation: {
               type: 'Integer',
               desc: 'PR Comment Count (Issue + PR comments in cycle) / PR 评论数量（周期内Issue与PR下评论总和）',
               example: 350,
               minimum: 0,
               nullable: true
             }
    end

    class PrCommentCountResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数' }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数' }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页' }
      expose :items, using: Entities::PrCommentCountItem,
             documentation: { type: 'PrCommentCountItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end
