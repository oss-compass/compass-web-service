class RemoveIsSameTypeCheckToTpcSoftwareSelectionReports < ActiveRecord::Migration[7.1]
  def change
    remove_column :tpc_software_selection_reports, :is_same_type_check
    remove_column :tpc_software_selection_reports, :same_type_software_name
  end
end
