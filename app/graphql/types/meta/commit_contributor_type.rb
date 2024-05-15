# frozen_string_literal: true

module Types
  module Meta
    class CommitContributorType < Types::BaseObject
      field :author_email, String
      field :org_name, String
      field :lines_added, Integer
      field :lines_removed, Integer
      field :lines_changed, Integer
      field :grimoire_creation_date, GraphQL::Types::ISO8601DateTime
    end
  end
end
