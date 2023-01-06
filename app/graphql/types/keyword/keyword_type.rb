# frozen_string_literal: true

module Types
  module Keyword
    class KeywordType < Types::BaseObject
      field :id, Integer
      field :title, String
      field :desc, String
    end
  end
end
