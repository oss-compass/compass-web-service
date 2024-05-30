# frozen_string_literal: true

module Types
  module Meta
    class SubjectAccessLevelPageType < BasePageObject
      field :items, [Types::Meta::SubjectAccessLevelType]
    end
  end
end
