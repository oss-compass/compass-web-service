# frozen_string_literal: true

module Types
  module Metric
    class CategoryOverviewType < Types::BaseObject
      field :category, String, description: 'category ident'
      field :items, [CategoryStatType]
    end
  end
end
