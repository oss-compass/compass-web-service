class RenameTpcSoftwareReportMetricClarificationStates < ActiveRecord::Migration[7.1]
  def change
    rename_table :tpc_software_report_metric_clarification_states, :tpc_software_comment_states

    rename_column :tpc_software_comment_states, :tpc_software_report_metric_id, :tpc_software_id

    add_column :tpc_software_comment_states, :tpc_software_type, :string, default: 'TpcSoftwareReportMetric', null: false
  end
end
