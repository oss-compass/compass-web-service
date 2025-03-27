class CreateTpcSoftwareLectotypeReportMetrics < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_lectotype_report_metrics do |t|
      t.string :code_url, null: false
      t.string :status, null: false
      t.integer :status_compass_callback, null: false
      t.integer :status_tpc_service_callback, null: false
      t.integer :version, null: false
      t.integer :tpc_software_report_id, null: false
      t.string :tpc_software_report_type, null: false
      t.integer :subject_id, null: false
      t.integer :user_id, null: false
      t.integer :base_repo_name
      t.integer :base_website_url
      t.integer :base_code_url
      t.integer :compliance_license
      t.integer :compliance_dco
      t.integer :compliance_package_sig
      t.integer :compliance_license_compatibility
      t.integer :ecology_dependency_acquisition
      t.integer :ecology_code_maintenance
      t.integer :ecology_community_support
      t.integer :ecology_adoption_analysis
      t.integer :ecology_software_quality
      t.integer :ecology_patent_risk
      t.integer :lifecycle_version_normalization
      t.integer :lifecycle_version_number
      t.integer :lifecycle_version_lifecycle
      t.integer :security_binary_artifact
      t.integer :security_vulnerability
      t.integer :security_vulnerability_response
      t.integer :security_vulnerability_disclosure
      t.integer :security_history_vulnerability
      t.string :base_repo_name_detail, limit: 500
      t.string :base_website_url_detail, limit: 500
      t.string :base_code_url_detail, limit: 500
      t.string :compliance_license_detail, limit: 500
      t.string :compliance_dco_detail, limit: 500
      t.string :compliance_package_sig_detail, limit: 500
      t.string :compliance_license_compatibility_detail, limit: 500
      t.string :ecology_dependency_acquisition_detail, limit: 500
      t.string :ecology_code_maintenance_detail, limit: 500
      t.string :ecology_community_support_detail, limit: 500
      t.string :ecology_adoption_analysis_detail, limit: 500
      t.string :ecology_software_quality_detail, limit: 500
      t.string :ecology_patent_risk_detail, limit: 500
      t.string :lifecycle_version_normalization_detail, limit: 500
      t.string :lifecycle_version_number_detail, limit: 500
      t.string :lifecycle_version_lifecycle_detail, limit: 500
      t.string :security_binary_artifact_detail, limit: 500
      t.string :security_vulnerability_detail, limit: 500
      t.string :security_vulnerability_response_detail, limit: 500
      t.string :security_vulnerability_disclosure_detail, limit: 500
      t.text :security_history_vulnerability_detail, limit: 5000

      t.timestamps
    end
  end
end
