# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareGraduationReportMetricClarificationCountType < Types::BaseObject

      field :compliance_license, Integer
      field :compliance_dco, Integer
      field :compliance_license_compatibility, Integer
      field :compliance_copyright_statement, Integer
      field :compliance_copyright_statement_anti_tamper, Integer
      field :compliance_snippet_reference, Integer

      field :ecology_readme, Integer
      field :ecology_build_doc, Integer
      field :ecology_interface_doc, Integer
      field :ecology_issue_management, Integer
      field :ecology_issue_response_ratio, Integer
      field :ecology_issue_response_time, Integer
      field :ecology_maintainer_doc, Integer
      field :ecology_build, Integer
      field :ecology_ci, Integer
      field :ecology_test_coverage, Integer
      field :ecology_code_review, Integer
      field :ecology_code_upstream, Integer

      field :lifecycle_release_note, Integer
      field :lifecycle_statement, Integer

      field :security_binary_artifact, Integer
      field :security_vulnerability, Integer
      field :security_package_sig, Integer

    end
  end
end
