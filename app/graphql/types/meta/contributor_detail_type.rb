# frozen_string_literal: true

module Types
  module Meta
    class ContributorDetailType < Types::BaseObject
      field :contributor, String
      field :ecological_type, String
      field :organization, String
      field :contribution, Integer
      field :contribution_without_observe, Integer
      field :is_bot, Boolean
      field :mileage_type, String
      field :contribution_type_list, [ContributionType]
    end
  end
end
