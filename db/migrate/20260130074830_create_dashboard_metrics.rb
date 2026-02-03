class CreateDashboardMetrics < ActiveRecord::Migration[7.1]
  def change
    create_table :dashboard_metrics do |t|
      t.string :name, null: false # 指标名称
      t.boolean :from_model, default: false # 是否来自模型
      t.boolean :hidden, default: false # 是否隐藏
      t.integer :dashboard_model_id # 关联的模型ID
      t.integer :dashboard_id # 指标所属的看板
      t.integer :dashboard_metric_info_id # 指标所属的看板
      t.string :dashboard_metric_info_ident
      t.string :dashboard_model_info_ident
      t.integer :sort
      t.timestamps
    end
  end
end
