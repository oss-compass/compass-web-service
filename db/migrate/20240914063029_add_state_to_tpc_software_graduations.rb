class AddStateToTpcSoftwareGraduations < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_graduations, :state, :integer, null: true
    add_column :tpc_software_graduations, :target_software_report_id, :integer, null: true
  end
end
