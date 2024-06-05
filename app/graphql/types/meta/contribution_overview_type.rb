# frozen_string_literal: true

module Types
  module Meta
    class ContributionOverviewType < Types::BaseObject
      field :current_period, Types::Meta::ContributionDetailOverviewType
      field :previous_period, Types::Meta::ContributionDetailOverviewType
      field :ratio, Types::Meta::ContributionDetailOverviewType
    end
  end
end
