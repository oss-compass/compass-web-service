class CreateTpcAutoCreateCommitters < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_auto_create_committers do |t|
      t.integer :tpc_auto_create_org_id, null: false
      t.string :gitcode_account, null: false, comment: "GitCode 用户名"
      t.string :role, default: 'push', comment: "权限级别: push, admin"
      t.timestamps
    end
  end
end
