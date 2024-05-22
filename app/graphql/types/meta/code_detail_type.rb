# frozen_string_literal: true

module Types
  module Meta
    class CodeDetailType < Types::BaseObject
      field :tag, String
      field :url, String
      field :title, String
      field :user_login, String
      field :created_at, GraphQL::Types::ISO8601DateTime
      field :merged_at, GraphQL::Types::ISO8601DateTime
      field :issue_num, String
      field :lines_total, Integer
      field :commit_urls, [String]
    end
  end
end
