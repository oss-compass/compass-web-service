# frozen_string_literal: true

module Types
  module Meta
    class ContributorDetailOverviewType < Types::BaseObject
      field :top_contributing_individual, ContributorType
      field :top_contributing_organization, ContributorType
      field :individual_participants_contribution_ratio, Float
      field :organization_managers_contribution_ratio, Float
    end
  end
end
