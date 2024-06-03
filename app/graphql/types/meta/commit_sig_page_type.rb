# frozen_string_literal: true

module Types
  module Meta
    class CommitSigPageType < BasePageObject
      field :items, [Types::Meta::CommitSigType]
    end
  end
end
