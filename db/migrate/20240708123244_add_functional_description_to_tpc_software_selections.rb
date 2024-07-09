class AddFunctionalDescriptionToTpcSoftwareSelections < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_selections, :functional_description, :string, null: true
  end
end
