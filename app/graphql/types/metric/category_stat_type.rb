# frozen_string_literal: true

module Types
  module Metric
    class CategoryStatType < Types::BaseObject
      field :ident, String
      field :result, CategoryStatValueType
    end
  end
end
