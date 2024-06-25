# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricType < Types::BaseObject
      field :id, Integer, null: false
      field :status, String, description: 'progress/success'
      field :tpc_software_report_id, Integer

      field :base_repo_name, Integer
      field :base_website_url, Integer
      field :base_code_url, Integer

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

      field :lifecycle_version_normalization, Integer
      field :lifecycle_version_number, Integer
      field :lifecycle_version_lifecycle, Integer

      field :security_binary_artifact, Integer
      field :security_vulnerability, Integer
      field :security_vulnerability_response, Integer
      field :security_vulnerability_disclosure, Integer
      field :security_history_vulnerability, Integer

      field :created_at, GraphQL::Types::ISO8601DateTime
      field :updated_at, GraphQL::Types::ISO8601DateTime
    end
  end
end
