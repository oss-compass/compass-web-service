# frozen_string_literal: true

module Types
  module Lab
    class ModelCommentPageType < Types::BaseObject
      field :count, Integer
      field :total_page, Integer
      field :page, Integer
      field :items, [Types::Lab::ModelCommentType]
    end
  end
end
