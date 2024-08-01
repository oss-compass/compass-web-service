# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareGraduationMetricEcologyIssueManagementType < Types::BaseObject
      field :issue_count, Integer
      field :issue_type_list, [String]
    end
  end
end
