# frozen_string_literal: true

module Types
  module Meta
    class PullDetailPageType < BasePageObject
      field :items, [Types::Meta::PullDetailType]
    end
  end
end
