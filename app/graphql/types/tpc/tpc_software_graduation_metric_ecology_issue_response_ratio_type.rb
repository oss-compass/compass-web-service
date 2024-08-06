# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareGraduationMetricEcologyIssueResponseRatioType < Types::BaseObject
      field :issue_count, Integer
      field :issue_response_count, Integer
      field :issue_response_ratio, Float
    end
  end
end
