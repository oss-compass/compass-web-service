# frozen_string_literal: true

module Types
  module Meta
    class CodeDetailPageType < BasePageObject
      field :items, [Types::Meta::CodeDetailType]
    end
  end
end
