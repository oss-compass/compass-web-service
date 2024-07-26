class CreateTpcSoftwareMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_members do |t|
      t.integer :user_id, null: true
      t.integer :member_type, null: false
      t.string :name, null: true
      t.string :company, null: true
      t.string :email, null: true
      t.string :github_account, null: true
      t.string :gitee_account, null: true
      t.integer :tpc_software_sig_id, null: true
      t.string :description, null: true
      t.integer :role_level, default: 0
      t.integer :subject_id, null: false
      t.timestamps
    end
  end
end
