class CreateTpcSoftwareGraduations < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_graduations do |t|
      t.string :tpc_software_graduation_report_ids, null: false
      t.datetime :incubation_start_time, null: true
      t.string :incubation_time, null: true
      t.string :demand_source, null: false
      t.string :committers, null: false
      t.string :issue_url, null: true
      t.integer :subject_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end
  end
end
