# frozen_string_literal: true

module Types
  module Keyword
    class KeywordOverviewType < Types::BaseObject
      field :count, Integer
      field :total_page, Integer
      field :page, Integer
      field :items, [Types::Keyword::KeywordType]
    end
  end
end
