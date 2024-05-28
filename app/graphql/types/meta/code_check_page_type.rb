# frozen_string_literal: true

module Types
  module Meta
    class CodeCheckPageType < BasePageObject
      field :items, [Types::Meta::CodeCheckType]
    end
  end
end
