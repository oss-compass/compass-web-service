# frozen_string_literal: true

module Types
  module Meta
    class CodeCheckDetailType < Types::BaseObject
      field :user_login, String
      field :pr_user_login, String
      field :pr_url, String
      field :pr_state, String
      field :issue_num, String
      field :comment_created_at, GraphQL::Types::ISO8601DateTime
      field :comment_num, Integer
      field :time_check_hours, Float
      field :lines_added, Integer
      field :lines_removed, Integer
    end
  end
end
