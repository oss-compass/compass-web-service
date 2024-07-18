class AddMemberTypeToTpcSoftwareReportMetricClarificationStates < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_report_metric_clarification_states, :member_type, :integer, default: 0, null: true
  end
end
