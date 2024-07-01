class AddMetricDetailToTpcSoftwareReportMetrics < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_report_metrics, :base_repo_name_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :base_website_url_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :base_code_url_detail, :string, limit: 500, null: true

    add_column :tpc_software_report_metrics, :compliance_license_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :compliance_dco_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :compliance_package_sig_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :compliance_license_compatibility_detail, :string, limit: 500, null: true

    add_column :tpc_software_report_metrics, :ecology_dependency_acquisition_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :ecology_code_maintenance_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :ecology_community_support_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :ecology_adoption_analysis_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :ecology_software_quality_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :ecology_patent_risk_detail, :string, limit: 500, null: true

    add_column :tpc_software_report_metrics, :lifecycle_version_normalization_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :lifecycle_version_number_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :lifecycle_version_lifecycle_detail, :string, limit: 500, null: true

    add_column :tpc_software_report_metrics, :security_binary_artifact_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :security_vulnerability_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :security_vulnerability_response_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :security_vulnerability_disclosure_detail, :string, limit: 500, null: true
    add_column :tpc_software_report_metrics, :security_history_vulnerability_detail, :string, limit: 5000, null: true
  end
end
