# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricComplianceLicenseCompatibilityType < Types::BaseObject
      field :license, String
      field :license_conflict_list, [String]

      field :tpc_detail, [Types::Tpc::TpcSoftwareReportMetricComplianceLicenseCompatibilityTpcType]
      field :oat_detail, [String]
    end
  end
end
