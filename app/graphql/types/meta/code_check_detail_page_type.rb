# frozen_string_literal: true

module Types
  module Meta
    class CodeCheckDetailPageType < BasePageObject
      field :items, [Types::Meta::CodeCheckDetailType]
    end
  end
end
