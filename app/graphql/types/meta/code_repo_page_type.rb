# frozen_string_literal: true

module Types
  module Meta
    class CodeRepoPageType < BasePageObject
      field :items, [Types::Meta::CodeRepoType]
    end
  end
end
