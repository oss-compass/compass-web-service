class ChangeRemoveAndAddIncubationTimeToTpcSoftwareSelections < ActiveRecord::Migration[7.1]
  def change
    remove_column :tpc_software_selections, :incubation_time
    remove_column :tpc_software_selections, :adaptation_method
    remove_column :tpc_software_selections, :issue_url

    add_column :tpc_software_selections, :incubation_time, :string, null: false
    add_column :tpc_software_selections, :adaptation_method, :string, null: false
  end
end
