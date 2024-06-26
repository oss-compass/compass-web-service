class ChangeReleaseNullInTpcSoftwareSelectionReports < ActiveRecord::Migration[7.1]
  def change
    change_column_null :tpc_software_selection_reports, :release, true
    change_column_null :tpc_software_selection_reports, :release_time, true
  end
end
