# frozen_string_literal: true

module Types
  module Meta
    class CommitOrganizationType < Types::BaseObject
      field :org_name, String
      field :lines_added, Integer
      field :lines_removed, Integer
      field :lines_changed, Integer
      field :lines_changed_ratio, Float
      field :total_lines_changed, Integer
    end
  end
end
