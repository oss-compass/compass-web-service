class AddComplianceSnippetReferenceToTpcSoftwareGraduationReportMetricRaws < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_graduation_report_metric_raws, :compliance_snippet_reference_raw, :text, null: true
  end
end
