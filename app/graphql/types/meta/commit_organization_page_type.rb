# frozen_string_literal: true

module Types
  module Meta
    class CommitOrganizationPageType < BasePageObject
      field :items, [Types::Meta::CommitOrganizationType]
    end
  end
end
