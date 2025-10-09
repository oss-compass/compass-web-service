# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricClarificationCountType < Types::BaseObject
      
      field :compliance_license, Integer
      field :compliance_dco, Integer
      field :compliance_package_sig, Integer
      field :compliance_license_compatibility, Integer

      field :ecology_dependency_acquisition, Integer
      field :ecology_code_maintenance, Integer
      field :ecology_community_support, Integer
      field :ecology_adoption_analysis, Integer
      field :ecology_software_quality, Integer
      field :ecology_patent_risk, Integer
      field :ecology_adaptation_method, Integer

      field :lifecycle_version_normalization, Integer
      field :lifecycle_version_number, Integer
      field :lifecycle_version_lifecycle, Integer

      field :security_binary_artifact, Integer
      field :security_vulnerability, Integer
      field :security_vulnerability_response, Integer
      field :security_vulnerability_disclosure, Integer
      field :security_history_vulnerability, Integer
      field :upstream_collaboration_strategy, Integer

    end
  end
end
