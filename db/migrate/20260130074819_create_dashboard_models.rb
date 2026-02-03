class CreateDashboardModels < ActiveRecord::Migration[7.1]
  def change
    create_table :dashboard_models do |t|
      t.string :name, null: false   # 模型名称
      t.string :description         # 介绍
      t.integer :dashboard_id       # 指标所属的看板
      t.integer :dashboard_model_info_id   # 指标所属的看板
      t.string  :dashboard_model_info_ident      # 指标所属的看板
      t.timestamps
    end
  end
end
