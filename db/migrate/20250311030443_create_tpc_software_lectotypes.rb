class CreateTpcSoftwareLectotypes < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_lectotypes do |t|

      t.string :tpc_software_lectotype_report_ids, null: false
      t.string :repo_url
      t.string :committers, null: false
      t.string :reason, null: false
      t.integer :subject_id, null: false
      t.integer :user_id, null: false
      t.string :incubation_time, null: false
      t.string :adaptation_method
      t.text :demand_source
      t.text :functional_description
      t.string :target_software
      t.integer :is_same_type_check, default: 0
      t.string :same_type_software_name
      t.string :issue_url
      t.integer :state
      t.integer :target_software_report_id
      t.timestamps
    end
  end
end
