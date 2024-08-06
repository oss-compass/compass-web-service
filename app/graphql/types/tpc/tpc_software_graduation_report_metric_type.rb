# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareGraduationReportMetricType < Types::BaseObject
      field :id, Integer, null: false
      field :status, String, description: 'progress/success'
      field :code_url, String
      field :tpc_software_graduation_report_id, Integer

      field :compliance_license, Integer
      field :compliance_license_detail, Types::Tpc::TpcSoftwareGraduationReportMetricComplianceLicenseType
      field :compliance_dco, Integer
      field :compliance_dco_detail, Types::Tpc::TpcSoftwareReportMetricComplianceDcoType
      field :compliance_license_compatibility, Integer
      field :compliance_license_compatibility_detail, [Types::Tpc::TpcSoftwareReportMetricComplianceLicenseCompatibilityType]
      field :compliance_copyright_statement, Integer
      field :compliance_copyright_statement_detail, String
      field :compliance_copyright_statement_anti_tamper, Integer
      field :compliance_copyright_statement_anti_tamper_detail, String

      field :ecology_readme, Integer
      field :ecology_readme_detail, String
      field :ecology_build_doc, Integer
      field :ecology_build_doc_detail, String
      field :ecology_interface_doc, Integer
      field :ecology_interface_doc_detail, String
      field :ecology_issue_management, Integer
      field :ecology_issue_management_detail, Types::Tpc::TpcSoftwareGraduationMetricEcologyIssueManagementType
      field :ecology_issue_response_ratio, Integer
      field :ecology_issue_response_ratio_detail, Types::Tpc::TpcSoftwareGraduationMetricEcologyIssueResponseRatioType
      field :ecology_issue_response_time, Integer
      field :ecology_issue_response_time_detail, Types::Tpc::TpcSoftwareGraduationMetricEcologyIssueResponseTimeType
      field :ecology_maintainer_doc, Integer
      field :ecology_maintainer_doc_detail, String
      field :ecology_build, Integer
      field :ecology_build_detail, String
      field :ecology_ci, Integer
      field :ecology_ci_detail, String
      field :ecology_test_coverage, Integer
      field :ecology_test_coverage_detail, Types::Tpc::TpcSoftwareReportMetricEcologySoftwareQualityType
      field :ecology_code_review, Integer
      field :ecology_code_review_detail, Types::Tpc::TpcSoftwareGraduationMetricEcologyCodeReviewType
      field :ecology_code_upstream, Integer
      field :ecology_code_upstream_detail, String

      field :lifecycle_release_note, Integer
      field :lifecycle_release_note_detail, [String]
      field :lifecycle_statement, Integer
      field :lifecycle_statement_detail, String

      field :security_binary_artifact, Integer
      field :security_binary_artifact_detail, [String]
      field :security_vulnerability, Integer
      field :security_vulnerability_detail, [Types::Tpc::TpcSoftwareReportMetricSecurityVulnerabilityType]
      field :security_package_sig, Integer
      field :security_package_sig_detail, [String]

      field :created_at, GraphQL::Types::ISO8601DateTime
      field :updated_at, GraphQL::Types::ISO8601DateTime

      [
        :compliance_license_detail,
        :compliance_dco_detail,
        :compliance_license_compatibility_detail,
        :compliance_copyright_statement_detail,
        :compliance_copyright_statement_anti_tamper_detail,
        :ecology_readme_detail,
        :ecology_build_doc_detail,
        :ecology_interface_doc_detail,
        :ecology_issue_management_detail,
        :ecology_issue_response_ratio_detail,
        :ecology_issue_response_time_detail,
        :ecology_maintainer_doc_detail,
        :ecology_build_detail,
        :ecology_ci_detail,
        :ecology_test_coverage_detail,
        :ecology_code_review_detail,
        :ecology_code_upstream_detail,
        :lifecycle_release_note_detail,
        :lifecycle_statement_detail,
        :security_binary_artifact_detail,
        :security_vulnerability_detail,
        :security_package_sig_detail
      ].each do |method_name|
        define_method(method_name) do
          value = object.send(method_name)
          return nil unless value.present?
          JSON.parse(value)
        end
      end

      def ecology_test_coverage
        quality_detail = object.ecology_test_coverage_detail.present? ? JSON.parse(object.ecology_test_coverage_detail) : {}
        if quality_detail.dig("duplication_ratio").nil? || quality_detail.dig("coverage_ratio").nil?
          -1
        else
          object.ecology_test_coverage
        end
      end

    end
  end
end
