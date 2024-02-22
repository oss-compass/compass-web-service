# frozen_string_literal: true

module Types
  module Meta
    class ContributorDetailPageType < BasePageObject
      field :items, [Types::Meta::ContributorDetailType], null: false
      field :origin, String, description: 'contributors origin', null: false
    end
  end
end
