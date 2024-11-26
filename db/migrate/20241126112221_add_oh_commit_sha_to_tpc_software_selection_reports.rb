class AddOhCommitShaToTpcSoftwareSelectionReports < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_selection_reports, :oh_commit_sha, :string
  end
end
