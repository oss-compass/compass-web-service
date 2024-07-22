# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricComplianceLicenseType < Types::BaseObject
      field :osi_permissive_licenses, [String]
      field :osi_copyleft_limited_licenses, [String]
      field :osi_free_restricted_licenses, [String]
      field :non_osi_licenses, [String]
    end
  end
end
