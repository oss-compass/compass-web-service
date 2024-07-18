class AddAdaptationMethodToTpcSoftwareSelectionReport < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_selection_reports, :adaptation_method, :string, null: true
  end
end
