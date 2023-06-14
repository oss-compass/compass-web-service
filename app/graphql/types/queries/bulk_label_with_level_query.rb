# frozen_string_literal: true

module Types
  module Queries
    class BulkLabelWithLevelQuery < BaseQuery
      type [Types::LabelRowType], null: false
      description 'Get bulk label and level by a short code list'
      argument :short_codes, [String], required: true, description: 'a list of short code'

      def resolve(short_codes: )
        result =
          if short_codes.present?
            short_codes.map do |short_code|
              ShortenedLabel.revert(short_code)
            end
          else
            []
          end
      end
    end
  end
end
