# frozen_string_literal: true

module Types
  module Lab
    class ModelCommentPageType < BasePageObject
      field :items, [Types::Lab::ModelCommentType]
    end
  end
end
