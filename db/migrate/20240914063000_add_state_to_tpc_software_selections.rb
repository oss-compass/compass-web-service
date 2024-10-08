class AddStateToTpcSoftwareSelections < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_selections, :state, :integer, null: true
    add_column :tpc_software_selections, :target_software_report_id, :integer, null: true
  end
end
