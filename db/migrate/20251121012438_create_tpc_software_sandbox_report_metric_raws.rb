class CreateTpcSoftwareSandboxReportMetricRaws < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_sandbox_report_metric_raws do |t|
      t.integer :tpc_software_report_metric_id, null: false
      t.string :code_url, null: false
      t.integer :subject_id, null: false

      t.text :compliance_license_raw
      t.text :compliance_package_sig_raw
      t.text :compliance_license_compatibility_raw
      t.text :ecology_dependency_acquisition_raw
      t.text :ecology_code_maintenance_raw
      # t.text :compliance_dco_raw
      # t.text :ecology_community_support_raw
      # t.text :ecology_adoption_analysis_raw
      # # t.text :ecology_patent_risk_raw
      t.text :ecology_software_quality_raw
      t.text :lifecycle_version_normalization_raw
      t.text :lifecycle_version_number_raw
      t.text :lifecycle_version_lifecycle_raw
      t.text :security_binary_artifact_raw
      t.text :security_vulnerability_raw
      t.text :security_vulnerability_response_raw
      t.text :security_vulnerability_disclosure_raw
      t.text :security_history_vulnerability_raw
      # t.string :tpc_software_report_metric_raw
      # t.string :upstream_collaboration_strategy_raw
      t.timestamps
    end
  end
end
