class CreateTpcSoftwareGraduationReports < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_graduation_reports do |t|
      t.string :short_code, null: false
      t.string :name, null: true
      t.integer :tpc_software_sig_id, null: true
      t.string :code_url, null: true
      t.string :upstream_code_url, null: true
      t.string :programming_language, null: false
      t.string :adaptation_method, null: false
      t.string :lifecycle_policy, limit: 500, null: false
      t.integer :subject_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end

    add_index :tpc_software_graduation_reports, [:short_code], unique: true
  end
end
