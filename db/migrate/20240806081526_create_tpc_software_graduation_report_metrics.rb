class CreateTpcSoftwareGraduationReportMetrics < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_graduation_report_metrics do |t|
      t.string :code_url, null: false
      t.string :status, null: false
      t.integer :status_compass_callback, null: false
      t.integer :status_tpc_service_callback, null: false
      t.integer :version, null: false
      t.integer :tpc_software_graduation_report_id, null: false
      t.integer :subject_id, null: false
      t.integer :user_id, null: false

      t.integer :compliance_license, null:true
      t.string :compliance_license_detail, limit:500, null: true
      t.integer :compliance_dco, null:true
      t.string :compliance_dco_detail, limit:500, null: true
      t.integer :compliance_license_compatibility, null:true
      t.string :compliance_license_compatibility_detail, limit:500, null: true
      t.integer :compliance_copyright_statement, null:true
      t.string :compliance_copyright_statement_detail, limit:500, null: true
      t.integer :compliance_copyright_statement_anti_tamper, null:true
      t.string :compliance_copyright_statement_anti_tamper_detail, limit:500, null: true

      t.integer :ecology_readme, null:true
      t.string :ecology_readme_detail, limit:500, null: true
      t.integer :ecology_build_doc, null:true
      t.string :ecology_build_doc_detail, limit:500, null: true
      t.integer :ecology_interface_doc, null:true
      t.string :ecology_interface_doc_detail, limit:500, null: true
      t.integer :ecology_issue_management, null:true
      t.string :ecology_issue_management_detail, limit:500, null: true
      t.integer :ecology_issue_response_ratio, null:true
      t.string :ecology_issue_response_ratio_detail, limit:500, null: true
      t.integer :ecology_issue_response_time, null:true
      t.string :ecology_issue_response_time_detail, limit:500, null: true
      t.integer :ecology_maintainer_doc, null:true
      t.string :ecology_maintainer_doc_detail, limit:500, null: true
      t.integer :ecology_build, null:true
      t.string :ecology_build_detail, limit:500, null: true
      t.integer :ecology_ci, null:true
      t.string :ecology_ci_detail, limit:500, null: true
      t.integer :ecology_test_coverage, null:true
      t.string :ecology_test_coverage_detail, limit:500, null: true
      t.integer :ecology_code_review, null:true
      t.string :ecology_code_review_detail, limit:500, null: true
      t.integer :ecology_code_upstream, null:true
      t.string :ecology_code_upstream_detail, limit:500, null: true

      t.integer :lifecycle_release_note, null:true
      t.string :lifecycle_release_note_detail, limit:500, null: true
      t.integer :lifecycle_statement, null:true
      t.string :lifecycle_statement_detail, limit:500, null: true

      t.integer :security_binary_artifact, null:true
      t.string :security_binary_artifact_detail, limit:500, null: true
      t.integer :security_vulnerability, null:true
      t.string :security_vulnerability_detail, limit:500, null: true
      t.integer :security_package_sig, null:true
      t.string :security_package_sig_detail, limit:500, null: true

      t.timestamps
    end
  end
end
