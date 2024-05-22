# frozen_string_literal: true

module Types
  module Meta
    class CommitTechTypeType < Types::BaseObject
      field :repo_technology_type, String
      field :lines_added, Integer
      field :lines_removed, Integer
      field :lines_changed, Integer
    end
  end
end
