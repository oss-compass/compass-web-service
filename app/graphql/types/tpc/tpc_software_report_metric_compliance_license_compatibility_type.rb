# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricComplianceLicenseCompatibilityType < Types::BaseObject
      field :license, String
      field :license_conflict_list, [String]
    end
  end
end
