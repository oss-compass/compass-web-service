# frozen_string_literal: true

module Types
  module Financial
    class VulnerablityFeedbackChannelDetailType < BaseObject

      field :repo_url, String, null: true
      field :vulnerablity_feedback_channels_details, VulnerablityFeedbackType, null: true

    end
  end
end
