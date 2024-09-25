# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareMyCreationAndReviewOverviewType < Types::BaseObject
      field :total_count, Integer
      field :awaiting_clarification_count, Integer
      field :awaiting_confirmation_count, Integer
      field :awaiting_review_count, Integer
      field :completed_count, Integer
      field :rejected_count, Integer
      field :incubation_count, Integer
      field :graduation_count, Integer
    end
  end
end
