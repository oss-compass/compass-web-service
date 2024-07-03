# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricComplianceLicenseType < Types::BaseObject
      field :license_access_list, [String]
      field :license_non_access_list, [String]

    end
  end
end
