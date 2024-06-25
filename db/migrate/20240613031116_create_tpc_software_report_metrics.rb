class CreateTpcSoftwareReportMetrics < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_report_metrics do |t|
      t.string :code_url, null: false
      t.string :status, null: false
      t.integer :status_compass_callback, null: false
      t.integer :status_tpc_service_callback, null: false
      t.integer :version, null: false
      t.integer :tpc_software_report_id, null: false
      t.string :tpc_software_report_type, null: false
      t.integer :subject_id, null: false
      t.integer :user_id, null: false

      t.integer :base_repo_name, null: true
      t.integer :base_website_url, null: true
      t.integer :base_code_url, null: true

      t.integer :compliance_license, null: true
      t.integer :compliance_dco, null: true
      t.integer :compliance_package_sig, null: true
      t.integer :compliance_license_compatibility, null: true

      t.integer :ecology_dependency_acquisition, null: true
      t.integer :ecology_code_maintenance, null: true
      t.integer :ecology_community_support, null: true
      t.integer :ecology_adoption_analysis, null: true
      t.integer :ecology_software_quality, null: true
      t.integer :ecology_patent_risk, null: true

      t.integer :lifecycle_version_normalization, null: true
      t.integer :lifecycle_version_number, null: true
      t.integer :lifecycle_version_lifecycle, null: true

      t.integer :security_binary_artifact, null: true
      t.integer :security_vulnerability, null: true
      t.integer :security_vulnerability_response, null: true
      t.integer :security_vulnerability_disclosure, null: true
      t.integer :security_history_vulnerability, null: true

      t.timestamps
    end
  end
end
