# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricClarificationStateType < Types::BaseObject
      
      field :compliance_license, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :compliance_dco, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :compliance_package_sig, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :compliance_license_compatibility, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]

      field :ecology_dependency_acquisition, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :ecology_code_maintenance, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :ecology_community_support, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :ecology_adoption_analysis, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :ecology_software_quality, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :ecology_patent_risk, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]

      field :lifecycle_version_normalization, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :lifecycle_version_number, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :lifecycle_version_lifecycle, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]

      field :security_binary_artifact, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :security_vulnerability, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :security_vulnerability_response, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :security_vulnerability_disclosure, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]
      field :security_history_vulnerability, [Types::Tpc::TpcSoftwareReportMetricClarificationStateDetailType]

    end
  end
end
