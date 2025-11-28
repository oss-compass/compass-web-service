class CreateTpcSoftwareSandboxReports < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_sandbox_reports do |t|
      t.integer :report_type, null: false
      t.string :name, null: false
      t.integer :tpc_software_sig_id, null: false
      t.string :release
      t.datetime :release_time
      t.string :manufacturer, null: false
      t.string :website_url, null: false
      t.string :code_url, null: false
      t.string :programming_language, null: false
      t.integer :code_count
      t.string :license
      t.string :vulnerability_disclosure
      # t.string :vulnerability_response
      t.string :short_code, null: false
      t.integer :subject_id, null: false
      t.integer :user_id, null: false
      t.string :adaptation_method
      t.string :oh_commit_sha
      t.integer :report_category
      # t.integer :upstream_collaboration_strategy
      # t.string :upstream_communication_link

      t.timestamps
    end
  end
end
