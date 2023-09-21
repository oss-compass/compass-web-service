# frozen_string_literal: true

module Types
  module Meta
    class IssueDetailPageType < BasePageObject
      field :items, [Types::Meta::IssueDetailType]
    end
  end
end
