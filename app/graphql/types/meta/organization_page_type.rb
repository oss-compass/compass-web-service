# frozen_string_literal: true

module Types
  module Meta
    class OrganizationPageType < BasePageObject
      field :items, [Types::Meta::OrganizationType]
    end
  end
end
