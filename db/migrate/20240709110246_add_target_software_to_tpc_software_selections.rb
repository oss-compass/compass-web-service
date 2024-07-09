class AddTargetSoftwareToTpcSoftwareSelections < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_selections, :target_software, :string, null: true
  end
end
