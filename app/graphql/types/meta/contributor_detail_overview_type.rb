# frozen_string_literal: true

module Types
  module Meta
    class ContributorDetailOverviewType < Types::BaseObject
      field :highest_contribution_contributor, ContributorType
      field :highest_contribution_organization, ContributorType
      field :org_all_count, Float
      field :contributor_all_count, Float
      field :ecological_distribution, [DistributionType]
    end
  end
end
