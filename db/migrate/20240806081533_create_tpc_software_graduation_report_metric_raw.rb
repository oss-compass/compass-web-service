class CreateTpcSoftwareGraduationReportMetricRaw < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_graduation_report_metric_raws do |t|
      t.integer :tpc_software_graduation_report_metric_id, null: false
      t.string :code_url, null: false
      t.integer :subject_id, null: false

      t.text :compliance_license_raw, null:true
      t.text :compliance_dco_raw, null:true
      t.text :compliance_license_compatibility_raw, null:true
      t.text :compliance_copyright_statement_raw, null:true
      t.text :compliance_copyright_statement_anti_tamper_raw, null:true

      t.text :ecology_readme_raw, null:true
      t.text :ecology_build_doc_raw, null:true
      t.text :ecology_interface_doc_raw, null:true
      t.text :ecology_issue_management_raw, null:true
      t.text :ecology_issue_response_ratio_raw, null:true
      t.text :ecology_issue_response_time_raw, null:true
      t.text :ecology_maintainer_doc_raw, null:true
      t.text :ecology_build_raw, null:true
      t.text :ecology_ci_raw, null:true
      t.text :ecology_test_coverage_raw, null:true
      t.text :ecology_code_review_raw, null:true
      t.text :ecology_code_upstream_raw, null:true

      t.text :lifecycle_release_note_raw, null:true
      t.text :lifecycle_statement_raw, null:true

      t.text :security_binary_artifact_raw, null:true
      t.text :security_vulnerability_raw, null:true
      t.text :security_package_sig_raw, null:true

      t.timestamps
    end

    add_index :tpc_software_graduation_report_metric_raws, [:tpc_software_graduation_report_metric_id], unique: true
  end
end
