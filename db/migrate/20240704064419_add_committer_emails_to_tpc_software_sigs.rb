class AddCommitterEmailsToTpcSoftwareSigs < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_sigs, :committer_emails, :string, limit: 1024, null: true
  end
end
