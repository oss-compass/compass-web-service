# frozen_string_literal: true
module Openapi
  module Entities

    class ContributionTypeResponse < Grape::Entity
      expose :commit, documentation: {
        type: Float,
        desc: 'Commit Percentage / 提交（commit）占比，百分比格式',
        example: 23.45
      }

      expose :pr, documentation: {
        type: Float,
        desc: 'Pull Request Percentage / PR（Pull Request）占比，百分比格式',
        example: 30.12
      }

      expose :pr_comment, documentation: {
        type: Float,
        desc: 'PR Comment Percentage / PR 评论占比，百分比格式',
        example: 10.25
      }

      expose :issue, documentation: {
        type: Float,
        desc: 'Issue Percentage / Issue 占比，百分比格式',
        example: 15.67
      }

      expose :issue_comment, documentation: {
        type: Float,
        desc: 'Issue Comment Percentage / Issue 评论占比，百分比格式',
        example: 8.42
      }

      expose :code_review, documentation: {
        type: Float,
        desc: 'Code Review Percentage / Code Review 占比，百分比格式',
        example: 12.09
      }
    end

  end

end
