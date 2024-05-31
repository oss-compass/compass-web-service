# frozen_string_literal: true

module Types
  module Meta
    class SubjectSigPageType < BasePageObject
      field :items, [Types::Meta::SubjectSigType]
    end
  end
end
