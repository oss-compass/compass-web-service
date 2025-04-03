# frozen_string_literal: true

module Types
  module Financial
    class EvaluateCodeReadabilityType < BaseObject

      field :File, String, null: true
      field :Language, String, null: true

      field :Comment, CommentType, null: true

      field :blank_lines, Integer, null: true
      field :avg_line_word_numbers, Float, null: true
      field :avg_identifier_length, Float, null: true
      field :identifier_word_ratio, Float, null: true
      field :keyword_frequency, Float, null: true
      field :avg_identifiers_per_line, Float, null: true
      field :total_lines, Integer, null: true

    end
  end
end
