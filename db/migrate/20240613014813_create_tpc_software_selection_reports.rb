class CreateTpcSoftwareSelectionReports < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_selection_reports do |t|
      t.integer :report_type, null: false
      t.string :name, null: false
      t.integer :tpc_software_sig_id, null: false
      t.string :release, null: false
      t.datetime :release_time, null: false
      t.string :manufacturer, null: false
      t.string :website_url, null: false
      t.string :code_url, null: false
      t.string :programming_language, null: false
      t.integer :code_count, null: true
      t.string :license, null: true
      t.string :vulnerability_disclosure, null: true
      t.string :vulnerability_response, null: true
      t.string :short_code, null: false
      t.integer :subject_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end
  end
end

