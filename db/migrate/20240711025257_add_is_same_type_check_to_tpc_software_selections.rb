class AddIsSameTypeCheckToTpcSoftwareSelections < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_selections, :is_same_type_check, :integer, default: 0, null: true
    add_column :tpc_software_selections, :same_type_software_name, :string, null: true
  end
end
