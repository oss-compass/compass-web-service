# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareGraduationReportMetricRawType < Types::BaseObject
      field :id, Integer, null: false
      field :code_url, String

      field :compliance_license_raw, String
      field :compliance_dco_raw, String
      field :compliance_license_compatibility_raw, String
      field :compliance_copyright_statement_raw, String
      field :compliance_copyright_statement_anti_tamper_raw, String
      field :compliance_snippet_reference_raw, String

      field :ecology_readme_raw, String
      field :ecology_build_doc_raw, String
      field :ecology_interface_doc_raw, String
      field :ecology_issue_management_raw, String
      field :ecology_issue_response_ratio_raw, String
      field :ecology_issue_response_time_raw, String
      field :ecology_maintainer_doc_raw, String
      field :ecology_build_raw, String
      field :ecology_ci_raw, String
      field :ecology_test_coverage_raw, String
      field :ecology_code_review_raw, String
      field :ecology_code_upstream_raw, String

      field :lifecycle_release_note_raw, String
      field :lifecycle_statement_raw, String

      field :security_binary_artifact_raw, String
      field :security_vulnerability_raw, String
      field :security_package_sig_raw, String

    end
  end
end
