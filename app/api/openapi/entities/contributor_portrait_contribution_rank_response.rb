# frozen_string_literal: true
module Openapi
  module Entities

    class ContributorPortraitContributionRankResponse < Grape::Entity
      expose :push_contribution, documentation: { type: 'int', desc: '代码贡献量', example: '' }
      expose :pull_request_contribution, documentation: { type: 'int', desc: 'PR创建贡献量', example: '' }
      expose :issue_contribution, documentation: { type: 'int', desc: 'Issue创建贡献量', example: '' }

      expose :push_contribution_rank, documentation: { type: 'String', desc: '代码贡献排名', example: '' }
      expose :pull_request_contribution_rank, documentation: { type: 'String', desc: 'PR创建贡献排名', example: '' }
      expose :issue_contribution_rank, documentation: { type: 'String', desc: 'Issue创建贡献排名', example: '' }
    end

  end
end
