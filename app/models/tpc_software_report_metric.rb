# == Schema Information
#
# Table name: tpc_software_report_metrics
#
#  id                                :bigint           not null, primary key
#  code_url                          :string(255)      not null
#  status                            :string(255)      not null
#  status_compass_callback           :integer          not null
#  status_tpc_service_callback       :integer          not null
#  version                           :integer          not null
#  tpc_software_report_id            :integer          not null
#  tpc_software_report_type          :string(255)      not null
#  subject_id                        :integer          not null
#  user_id                           :integer          not null
#  base_repo_name                    :integer
#  base_website_url                  :integer
#  base_code_url                     :integer
#  compliance_license                :integer
#  compliance_dco                    :integer
#  compliance_package_sig            :integer
#  compliance_license_compatibility  :integer
#  ecology_dependency_acquisition    :integer
#  ecology_code_maintenance          :integer
#  ecology_community_support         :integer
#  ecology_adoption_analysis         :integer
#  ecology_software_quality          :integer
#  ecology_patent_risk               :integer
#  lifecycle_version_normalization   :integer
#  lifecycle_version_number          :integer
#  lifecycle_version_lifecycle       :integer
#  security_binary_artifact          :integer
#  security_vulnerability            :integer
#  security_vulnerability_response   :integer
#  security_vulnerability_disclosure :integer
#  security_history_vulnerability    :integer
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#
class TpcSoftwareReportMetric < ApplicationRecord

  belongs_to :tpc_software_report, polymorphic: true
  belongs_to :subject
  belongs_to :user

  Status_Progress = 'progress'
  Status_Success = 'success'

  Version_History = 0
  Version_Default = 1

  Report_Type_Selection = 'TpcSoftwareSelectionReport'
  Report_Type_Output = 'TpcSoftwareOutputReport'

end
