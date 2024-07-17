# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricClarificationStateType < Types::BaseObject
      
      field :compliance_license, [Types::Tpc::TpcSoftwareCommentStateType]
      field :compliance_dco, [Types::Tpc::TpcSoftwareCommentStateType]
      field :compliance_package_sig, [Types::Tpc::TpcSoftwareCommentStateType]
      field :compliance_license_compatibility, [Types::Tpc::TpcSoftwareCommentStateType]

      field :ecology_dependency_acquisition, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_code_maintenance, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_community_support, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_adoption_analysis, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_software_quality, [Types::Tpc::TpcSoftwareCommentStateType]
      field :ecology_patent_risk, [Types::Tpc::TpcSoftwareCommentStateType]

      field :lifecycle_version_normalization, [Types::Tpc::TpcSoftwareCommentStateType]
      field :lifecycle_version_number, [Types::Tpc::TpcSoftwareCommentStateType]
      field :lifecycle_version_lifecycle, [Types::Tpc::TpcSoftwareCommentStateType]

      field :security_binary_artifact, [Types::Tpc::TpcSoftwareCommentStateType]
      field :security_vulnerability, [Types::Tpc::TpcSoftwareCommentStateType]
      field :security_vulnerability_response, [Types::Tpc::TpcSoftwareCommentStateType]
      field :security_vulnerability_disclosure, [Types::Tpc::TpcSoftwareCommentStateType]
      field :security_history_vulnerability, [Types::Tpc::TpcSoftwareCommentStateType]

    end
  end
end
