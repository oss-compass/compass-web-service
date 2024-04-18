# frozen_string_literal: true

module Types
  module Meta
    class RepoPageType < BasePageObject
      field :items, [Types::Meta::SubRepoType]
    end
  end
end
