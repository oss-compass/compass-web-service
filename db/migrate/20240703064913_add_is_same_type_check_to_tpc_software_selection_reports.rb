class AddIsSameTypeCheckToTpcSoftwareSelectionReports < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_selection_reports, :is_same_type_check, :integer, null: true
    add_column :tpc_software_selection_reports, :same_type_software_name, :string, null: true
  end
end
