# frozen_string_literal: true
module Openapi
  module Entities

    class ContributorContributionOverviewResponse < Grape::Entity


      expose :commit_count, documentation: {
        type: Integer,
        desc: 'Total number of commits / 总提交次数',
        example: 156
      }

      expose :pr_count, documentation: {
        type: Integer,
        desc: 'Total number of pull requests created / 创建的拉取请求总数',
        example: 24
      }

      expose :issue_count, documentation: {
        type: Integer,
        desc: 'Total number of issues created or participated / 创建或参与的问题总数',
        example: 18
      }

      expose :code_review_count, documentation: {
        type: Integer,
        desc: 'Number of code reviews performed / 进行的代码审查次数',
        example: 87
      }

      expose :contributed_to_count, documentation: {
        type: Integer,
        desc: 'Number of repositories contributed to / 参与贡献过的仓库总数',
        example: 12
      }

      expose :level, documentation: {
        type: String,
        desc: 'Contributor level / 贡献者等级',
        example: 'A'
      }
    end

  end
end
