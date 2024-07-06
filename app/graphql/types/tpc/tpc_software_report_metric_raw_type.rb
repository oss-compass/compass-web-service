# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricRawType < Types::BaseObject
      field :id, Integer, null: false
      field :code_url, String

      field :compliance_license_raw, String
      field :compliance_dco_raw, String
      field :compliance_package_sig_raw, String
      field :compliance_license_compatibility_raw, String

      field :ecology_dependency_acquisition_raw, String
      field :ecology_code_maintenance_raw, String
      field :ecology_community_support_raw, String
      field :ecology_adoption_analysis_raw, String
      field :ecology_software_quality_raw, String
      field :ecology_patent_risk_raw, String

      field :lifecycle_version_normalization_raw, String
      field :lifecycle_version_number_raw, String
      field :lifecycle_version_lifecycle_raw, String

      field :security_binary_artifact_raw, String
      field :security_vulnerability_raw, String
      field :security_vulnerability_response_raw, String
      field :security_vulnerability_disclosure_raw, String
      field :security_history_vulnerability_raw, String

    end
  end
end
