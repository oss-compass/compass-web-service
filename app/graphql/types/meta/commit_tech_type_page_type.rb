# frozen_string_literal: true

module Types
  module Meta
    class CommitTechTypePageType < BasePageObject
      field :items, [Types::Meta::CommitTechTypeType]
    end
  end
end
