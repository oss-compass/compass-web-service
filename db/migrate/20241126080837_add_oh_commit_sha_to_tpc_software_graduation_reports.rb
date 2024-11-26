class AddOhCommitShaToTpcSoftwareGraduationReports < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_graduation_reports, :oh_commit_sha, :string,limit:255, null: true
  end
end
