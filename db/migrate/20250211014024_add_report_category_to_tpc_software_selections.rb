class AddReportCategoryToTpcSoftwareSelections < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_selections, :report_category, :integer
  end
end
