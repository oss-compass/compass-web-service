# frozen_string_literal: true

module Types
  module Meta
    class IssueDetailType < Types::BaseObject
      field :repository, String
      field :id_in_repo, Integer
      field :url, String
      field :title, String
      field :state, String
      field :created_at, GraphQL::Types::ISO8601DateTime
      field :closed_at, GraphQL::Types::ISO8601DateTime
      field :time_to_close_days, Float
      field :time_to_first_attention_without_bot, Float
      field :labels, [String]
      field :user_login, String
      field :assignee_login, String
      field :num_of_comments_without_bot, Integer
    end
  end
end
