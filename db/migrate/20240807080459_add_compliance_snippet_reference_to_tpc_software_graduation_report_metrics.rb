class AddComplianceSnippetReferenceToTpcSoftwareGraduationReportMetrics < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_graduation_report_metrics, :compliance_snippet_reference, :integer, null: true
    add_column :tpc_software_graduation_report_metrics, :compliance_snippet_reference_detail, :string, limit:500, null: true
  end
end
