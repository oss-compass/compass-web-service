# frozen_string_literal: true
module Types
  module Meta
    class ContributorTopOverviewType < Types::BaseObject
      field :ecological_type, String
      field :ecological_type_percentage, Float
      field :top_contributor_distribution, [DistributionType]
    end
  end
end
