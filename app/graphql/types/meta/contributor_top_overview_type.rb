# frozen_string_literal: true
module Types
  module Meta
    class ContributorTopOverviewType < Types::BaseObject
      field :overview_name, String
      field :sub_type_name, String
      field :sub_type_percentage, Float
      field :top_contributor_distribution, [DistributionType]
    end
  end
end
