# == Schema Information
#
# Table name: tpc_software_sandbox_report_metric_raws
#
#  id                                    :bigint           not null, primary key
#  tpc_software_report_metric_id         :integer          not null
#  code_url                              :string(255)      not null
#  subject_id                            :integer          not null
#  compliance_license_raw                :text(65535)
#  compliance_package_sig_raw            :text(65535)
#  compliance_license_compatibility_raw  :text(65535)
#  ecology_dependency_acquisition_raw    :text(65535)
#  ecology_code_maintenance_raw          :text(65535)
#  ecology_software_quality_raw          :text(65535)
#  lifecycle_version_normalization_raw   :text(65535)
#  lifecycle_version_number_raw          :text(65535)
#  lifecycle_version_lifecycle_raw       :text(65535)
#  security_binary_artifact_raw          :text(65535)
#  security_vulnerability_raw            :text(65535)
#  security_vulnerability_response_raw   :text(65535)
#  security_vulnerability_disclosure_raw :text(65535)
#  security_history_vulnerability_raw    :text(65535)
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#
class TpcSoftwareSandboxReportMetricRaw < ApplicationRecord

  belongs_to :tpc_software_sandbox_report_metric,
             foreign_key: 'tpc_software_report_metric_id'
  belongs_to :subject
end
