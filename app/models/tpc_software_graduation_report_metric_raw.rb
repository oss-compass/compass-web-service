# == Schema Information
#
# Table name: tpc_software_graduation_report_metric_raws
#
#  id                                             :bigint           not null, primary key
#  tpc_software_graduation_report_metric_id       :integer          not null
#  code_url                                       :string(255)      not null
#  subject_id                                     :integer          not null
#  compliance_license_raw                         :text(65535)
#  compliance_dco_raw                             :text(65535)
#  compliance_license_compatibility_raw           :text(65535)
#  compliance_copyright_statement_raw             :text(65535)
#  compliance_copyright_statement_anti_tamper_raw :text(65535)
#  ecology_readme_raw                             :text(65535)
#  ecology_build_doc_raw                          :text(65535)
#  ecology_interface_doc_raw                      :text(65535)
#  ecology_issue_management_raw                   :text(65535)
#  ecology_issue_response_ratio_raw               :text(65535)
#  ecology_issue_response_time_raw                :text(65535)
#  ecology_maintainer_doc_raw                     :text(65535)
#  ecology_build_raw                              :text(65535)
#  ecology_ci_raw                                 :text(65535)
#  ecology_test_coverage_raw                      :text(65535)
#  ecology_code_review_raw                        :text(65535)
#  ecology_code_upstream_raw                      :text(65535)
#  lifecycle_release_note_raw                     :text(65535)
#  lifecycle_statement_raw                        :text(65535)
#  security_binary_artifact_raw                   :text(65535)
#  security_vulnerability_raw                     :text(65535)
#  security_package_sig_raw                       :text(65535)
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  compliance_snippet_reference_raw               :text(65535)
#  import_valid_raw                               :text(65535)
#
# Indexes
#
#  idx_on_tpc_software_graduation_report_metric_id_ff1401468a  (tpc_software_graduation_report_metric_id) UNIQUE
#
class TpcSoftwareGraduationReportMetricRaw < ApplicationRecord

  belongs_to :tpc_software_graduation_report_metric
  belongs_to :subject


end
