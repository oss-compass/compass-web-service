class AddIssueUrlToTpcSoftwareSelections < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_selections, :issue_url, :string, null: true
  end
end
