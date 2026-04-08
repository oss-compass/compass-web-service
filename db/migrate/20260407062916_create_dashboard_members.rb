class CreateDashboardMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :dashboard_members do |t|
      t.references :dashboard, null: false, foreign_key: true, comment: '看板ID'
      t.references :user, null: false, foreign_key: true, comment: '用户ID'
      t.integer :role, null: false, default: 0, comment: '角色：0-查看者, 1-编辑者, 2-管理员'
      t.integer :status, null: false, default: 0, comment: '状态：0-正常, 1-禁用'
      t.references :invited_by, foreign_key: { to_table: :users }, comment: '邀请人'
      t.datetime :joined_at, default: -> { 'CURRENT_TIMESTAMP' }, comment: '加入时间'
      t.text :remark, comment: '备注'
    end
  end
end
