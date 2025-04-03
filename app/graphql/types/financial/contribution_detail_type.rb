# frozen_string_literal: true

module Types
  module Financial
    class ContributionDetailType < BaseObject

      field :org_contribution, Integer, null: true
      field :personal, Integer, null: true
      field :organization, Integer, null: true

    end
  end
end
