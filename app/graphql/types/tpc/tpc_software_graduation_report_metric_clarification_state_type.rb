# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareGraduationReportMetricClarificationStateType < Types::BaseObject

      field :compliance_license, [Types::Tpc::TpcSoftwareCommentStateType]
      field :compliance_dco, [Types::Tpc::TpcSoftwareCommentStateType]
      field :compliance_license_compatibility, [Types::Tpc::TpcSoftwareCommentStateType]
      field :compliance_copyright_statement, [Types::Tpc::TpcSoftwareCommentStateType]
      field :compliance_copyright_statement_anti_tamper, [Types::Tpc::TpcSoftwareCommentStateType]

      field :ecology_readme, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_build_doc, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_interface_doc, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_issue_management, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_issue_response_ratio, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_issue_response_time, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_maintainer_doc, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_build, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_ci, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_test_coverage, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_code_review, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_code_upstream, [Types::Tpc::TpcSoftwareCommentStateType]

      field :lifecycle_release_note, [Types::Tpc::TpcSoftwareCommentStateType]
      field :lifecycle_statement, [Types::Tpc::TpcSoftwareCommentStateType]

      field :security_binary_artifact, [Types::Tpc::TpcSoftwareCommentStateType]
      field :security_vulnerability, [Types::Tpc::TpcSoftwareCommentStateType]
      field :security_package_sig, [Types::Tpc::TpcSoftwareCommentStateType]

    end
  end
end
