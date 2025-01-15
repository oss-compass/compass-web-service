class AddImportValidTpcSoftwareGraduationReportMetricRaws < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:tpc_software_graduation_report_metric_raws, :import_valid_raw)
      add_column :tpc_software_graduation_report_metric_raws, :import_valid_raw, :text, null: true
    end
  end
end
