# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareGraduationMetricEcologyCodeReviewType < Types::BaseObject
      field :pull_count, Integer
      field :pull_review_count, Integer
      field :pull_review_ratio, Float
    end
  end
end
