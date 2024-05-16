# frozen_string_literal: true

module Types
  module Meta
    class CommitDetailPageType < BasePageObject
      field :items, [Types::Meta::CommitDetailType]
    end
  end
end
