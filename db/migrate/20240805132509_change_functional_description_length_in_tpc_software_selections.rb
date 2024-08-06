class ChangeFunctionalDescriptionLengthInTpcSoftwareSelections < ActiveRecord::Migration[7.1]
  def change
    change_column :tpc_software_selections, :functional_description, :string, limit: 2000
    change_column :tpc_software_selections, :demand_source, :string, limit: 2000
  end
end
