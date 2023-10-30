# frozen_string_literal: true

module Types
  module Meta
    class ContributionType < Types::BaseObject
      field :contribution, Integer
      field :contribution_type, String
    end
  end
end
