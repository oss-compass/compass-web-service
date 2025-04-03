# frozen_string_literal: true

module Types
  module Financial
    class CommentType < BaseObject

      field :comment_ratio, Float, null: true
      field :comment_lines, Float, null: true
      field :total_lines, Float, null: true

    end
  end
end
