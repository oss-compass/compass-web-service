class AddUpstreamFieldsToTpcSoftwareSelectionReports < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:tpc_software_selection_reports, :upstream_collaboration_strategy)
      add_column :tpc_software_selection_reports, :upstream_collaboration_strategy, :integer
    end

    unless column_exists?(:tpc_software_selection_reports, :upstream_communication_link)
      add_column :tpc_software_selection_reports, :upstream_communication_link, :string
    end
  end
end
