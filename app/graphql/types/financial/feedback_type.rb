# frozen_string_literal: true

module Types
  module Financial
    class FeedbackType < BaseObject

      field :document_name, String, null: true
      field :document_path, String, null: true
      field :vulnerablity_feedback, [String], null: true

    end
  end
end
