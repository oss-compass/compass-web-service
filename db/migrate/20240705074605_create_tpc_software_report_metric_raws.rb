class CreateTpcSoftwareReportMetricRaws < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_report_metric_raws do |t|
      t.integer :tpc_software_report_metric_id, null: false
      t.string :code_url, null: false
      t.integer :subject_id, null: false

      t.text :compliance_license_raw, null: true
      t.text :compliance_dco_raw, null: true
      t.text :compliance_package_sig_raw, null: true
      t.text :compliance_license_compatibility_raw, null: true

      t.text :ecology_dependency_acquisition_raw, null: true
      t.text :ecology_code_maintenance_raw, null: true
      t.text :ecology_community_support_raw, null: true
      t.text :ecology_adoption_analysis_raw, null: true
      t.text :ecology_software_quality_raw, null: true
      t.text :ecology_patent_risk_raw, null: true

      t.text :lifecycle_version_normalization_raw, null: true
      t.text :lifecycle_version_number_raw, null: true
      t.text :lifecycle_version_lifecycle_raw, null: true

      t.text :security_binary_artifact_raw, null: true
      t.text :security_vulnerability_raw, null: true
      t.text :security_vulnerability_response_raw, null: true
      t.text :security_vulnerability_disclosure_raw, null: true
      t.text :security_history_vulnerability_raw, null: true

      t.timestamps
    end

    add_index :tpc_software_report_metric_raws, [:tpc_software_report_metric_id], unique: true
  end
end
