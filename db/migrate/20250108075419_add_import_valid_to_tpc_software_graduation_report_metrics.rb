class AddImportValidToTpcSoftwareGraduationReportMetrics < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_graduation_report_metrics, :import_valid, :integer, null: true
    add_column :tpc_software_graduation_report_metrics, :import_valid_detail, :string, limit:500, null: true
  end
end
