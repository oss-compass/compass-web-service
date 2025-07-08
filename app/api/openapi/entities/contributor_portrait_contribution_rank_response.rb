# frozen_string_literal: true
module Openapi
  module Entities

    class ContributorPortraitContributionRankResponse < Grape::Entity
      expose :push_contribution, documentation: { type: 'int', desc: 'Code Contribution Count / 代码贡献量', example: '' }
      expose :pull_request_contribution, documentation: { type: 'int', desc: 'PR Creation Contribution Count / PR创建贡献量', example: '' }
      expose :issue_contribution, documentation: { type: 'int', desc: 'Issue Creation Contribution Count / Issue创建贡献量', example: '' }

      expose :push_contribution_rank, documentation: { type: 'String', desc: 'Code Contribution Rank / 代码贡献排名', example: '' }
      expose :pull_request_contribution_rank, documentation: { type: 'String', desc: 'PR Creation Contribution Rank / PR创建贡献排名', example: '' }
      expose :issue_contribution_rank, documentation: { type: 'String', desc: 'Issue Creation Contribution Rank / Issue创建贡献排名', example: '' }
    end

  end
end
