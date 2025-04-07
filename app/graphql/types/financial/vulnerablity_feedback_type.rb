# frozen_string_literal: true

module Types
  module Financial
    class VulnerablityFeedbackType < BaseObject

      field :vulnerablity_feedback_channels, Integer, null: true
      field :vulnerablity_feedback_channels_details, [FeedbackType], null: true

    end
  end
end
