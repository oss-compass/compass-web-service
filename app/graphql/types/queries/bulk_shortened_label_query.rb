# frozen_string_literal: true

module Types
  module Queries
    class BulkShortenedLabelQuery < BaseQuery
      type [Types::LabelRowType], null: false
      description 'Get bulk shortened id for a label list'
      argument :labels, [Input::LabelRowInput], required: true, description: 'a list of label'

      def resolve(labels: )
        result =
          if labels.present?
            labels.map do |row|
              row.to_h.merge(short_code: ShortenedLabel.convert(row[:label], row[:level]))
            end
          else
            []
          end
      end
    end
  end
end
