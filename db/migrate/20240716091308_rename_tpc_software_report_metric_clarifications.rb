class RenameTpcSoftwareReportMetricClarifications < ActiveRecord::Migration[7.1]
  def change
    rename_table :tpc_software_report_metric_clarifications, :tpc_software_comments

    rename_column :tpc_software_comments, :tpc_software_report_metric_id, :tpc_software_id

    add_column :tpc_software_comments, :tpc_software_type, :string, default: 'TpcSoftwareReportMetric', null: false
  end
end
