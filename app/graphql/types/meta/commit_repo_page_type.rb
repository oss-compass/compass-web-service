# frozen_string_literal: true

module Types
  module Meta
    class CommitRepoPageType < BasePageObject
      field :items, [Types::Meta::CommitRepoType]
    end
  end
end
