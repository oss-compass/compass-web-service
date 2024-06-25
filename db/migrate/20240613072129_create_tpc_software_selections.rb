class CreateTpcSoftwareSelections < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_selections do |t|
      t.integer :selection_type, null: false
      t.string :tpc_software_selection_report_ids, null: false
      t.string :repo_url, null: true
      t.string :committers, null: false
      t.datetime :incubation_time, null: false
      t.integer :adaptation_method, null: false
      t.string :reason, null: false
      t.integer :subject_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end
  end
end
