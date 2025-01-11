# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareGraduationReportMetricComplianceLicenseType < Types::BaseObject
      field :osi_permissive_licenses, [String]
      field :non_osi_licenses, [String]
      field :oat_detail, [String]
    end
  end
end
