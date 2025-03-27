class AddReportCategoryToTpcSoftwareSelectionReports < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_selection_reports, :report_category, :integer
  end
end
