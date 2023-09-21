# frozen_string_literal: true

module Types
  module Metric
    class CategoryStatValueType < Types::BaseUnion
      description "The value of category stat item"
      possible_types StrType, NumType, DecimalType

      def self.resolve_type(object, _context)
        if object[:value].is_a?(String)
          StrType
        elsif object[:value].is_a?(Float)
          DecimalType
        else
          NumType
        end
      end
    end
  end
end
