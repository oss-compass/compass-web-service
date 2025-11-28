class CreateTpcSoftwareSandboxes < ActiveRecord::Migration[7.1]
  def change

    create_table :tpc_software_sandboxes do |t|
      t.string :tpc_software_sandbox_report_ids, null: false
      t.string :repo_url
      t.string :committers, null: false
      t.string :adaptation_committers
      t.integer :subject_id, null: false
      t.integer :user_id, null: false
      # t.integer :selection_type, null: false
      # t.string :reason, null: false
      # t.string :issue_url
      # t.string :incubation_time, null: false
      # # t.string :demand_source, limit: 2000
      t.string :adaptation_method
      t.string :functional_description, limit: 2000
      t.string :target_software
      t.integer :is_same_type_check, default: 0
      t.string :same_type_software_name
      t.integer :state
      t.integer :target_software_report_id
      t.integer :report_category
      t.string :remark

      t.timestamps
    end

  end
end
