class CreateDashboards < ActiveRecord::Migration[7.1]
  def change
    create_table :dashboards do |t|
      t.string :name, null: false # 名称
      t.string :dashboard_type # 类型 ( 社区,  仓库)
      t.string :repo_urls # 仓库/社区 地址 (多个)
      t.string :competitor_urls # 竞品地址 (多个)
      t.integer :user_id, null: false
      t.string :identifier
      t.timestamps
    end
  end
end
