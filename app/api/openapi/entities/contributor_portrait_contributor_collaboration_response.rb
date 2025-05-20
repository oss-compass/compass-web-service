# frozen_string_literal: true
module Openapi
  module Entities

    class ContributorPortraitContributorCollaborationResponse < Grape::Entity
      expose :to_contributor, documentation: { type: 'String', desc: '贡献者', example: '' }
      expose :pull_request_contribution, documentation: { type: 'int', desc: 'PR创建贡献量', example: '' }
      expose :pull_request_comment_contribution, documentation: { type: 'int', desc: 'PR评论贡献量', example: '' }
      expose :issue_contribution, documentation: { type: 'int', desc: 'Issue创建贡献量', example: '' }
      expose :issue_comment_contribution, documentation: { type: 'int', desc: 'Issue评论贡献量', example: '' }
      expose :total_contribution, documentation: { type: 'int', desc: '总贡献量', example: '' }
    end

  end
end
