class AddDemandSourceToTpcSoftwareSelections < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_selections, :demand_source, :string, null: true
  end
end
