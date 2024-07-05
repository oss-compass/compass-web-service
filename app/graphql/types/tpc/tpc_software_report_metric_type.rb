# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricType < Types::BaseObject
      field :id, Integer, null: false
      field :status, String, description: 'progress/success'
      field :code_url, String
      field :tpc_software_report_id, Integer

      field :base_repo_name, Integer
      field :base_repo_name_detail, String
      field :base_website_url, Integer
      field :base_website_url_detail, String
      field :base_code_url, Integer
      field :base_code_url_detail, String

      field :compliance_license, Integer
      field :compliance_license_detail, Types::Tpc::TpcSoftwareReportMetricComplianceLicenseType
      field :compliance_dco, Integer
      field :compliance_dco_detail, Types::Tpc::TpcSoftwareReportMetricComplianceDcoType
      field :compliance_package_sig, Integer
      field :compliance_package_sig_detail, [String]
      field :compliance_license_compatibility, Integer
      field :compliance_license_compatibility_detail, [Types::Tpc::TpcSoftwareReportMetricComplianceLicenseCompatibilityType]

      field :ecology_dependency_acquisition, Integer
      field :ecology_dependency_acquisition_detail, [String]
      field :ecology_code_maintenance, Integer
      field :ecology_code_maintenance_detail, String
      field :ecology_community_support, Integer
      field :ecology_community_support_detail, String
      field :ecology_adoption_analysis, Integer
      field :ecology_adoption_analysis_detail, String
      field :ecology_software_quality, Integer
      field :ecology_software_quality_detail, Types::Tpc::TpcSoftwareReportMetricEcologySoftwareQualityType
      field :ecology_patent_risk, Integer
      field :ecology_patent_risk_detail, String

      field :lifecycle_version_normalization, Integer
      field :lifecycle_version_normalization_detail, String
      field :lifecycle_version_number, Integer
      field :lifecycle_version_number_detail, String
      field :lifecycle_version_lifecycle, Integer
      field :lifecycle_version_lifecycle_detail, Types::Tpc::TpcSoftwareReportMetricLifecycleVersionLifecycleType

      field :security_binary_artifact, Integer
      field :security_binary_artifact_detail, [String]
      field :security_vulnerability, Integer
      field :security_vulnerability_detail, [Types::Tpc::TpcSoftwareReportMetricSecurityVulnerabilityType]
      field :security_vulnerability_response, Integer
      field :security_vulnerability_response_detail, String
      field :security_vulnerability_disclosure, Integer
      field :security_vulnerability_disclosure_detail, String
      field :security_history_vulnerability, Integer
      field :security_history_vulnerability_detail, [Types::Tpc::TpcSoftwareReportMetricSecurityHistoryVulnerabilityType]

      field :created_at, GraphQL::Types::ISO8601DateTime
      field :updated_at, GraphQL::Types::ISO8601DateTime

      [
        :base_repo_name_detail,
        :base_website_url_detail,
        :base_code_url_detail,
        :compliance_license_detail,
        :compliance_dco_detail,
        :compliance_package_sig_detail,
        :compliance_license_compatibility_detail,
        :ecology_dependency_acquisition_detail,
        :ecology_adoption_analysis_detail,
        :ecology_software_quality_detail,
        :ecology_patent_risk_detail,
        :lifecycle_version_normalization_detail,
        :lifecycle_version_number_detail,
        :lifecycle_version_lifecycle_detail,
        :security_binary_artifact_detail,
        :security_vulnerability_detail,
        :security_vulnerability_response_detail,
        :security_vulnerability_disclosure_detail,
        :security_history_vulnerability_detail
      ].each do |method_name|
        define_method(method_name) do
          value = object.send(method_name)
          return nil unless value.present?
          JSON.parse(value)
        end
      end

      def ecology_code_maintenance_detail
        object.code_url
      end

      def ecology_community_support_detail
        object.code_url
      end

      def ecology_software_quality
        quality_detail = object.ecology_software_quality_detail.present? ? JSON.parse(object.ecology_software_quality_detail) : {}
        if quality_detail.dig("duplication_ratio").nil?
          -1
        else
          object.ecology_software_quality
        end
      end
    end
  end
end
