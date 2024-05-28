# frozen_string_literal: true

module Types
  module Meta
    class CommitFeedbackPageType < BasePageObject
      field :items, [Types::Meta::CommitFeedbackType]
    end
  end
end
