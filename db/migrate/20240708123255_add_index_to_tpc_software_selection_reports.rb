class AddIndexToTpcSoftwareSelectionReports < ActiveRecord::Migration[7.1]
  def change
    add_index :tpc_software_selection_reports, :short_code, unique: true
  end
end
