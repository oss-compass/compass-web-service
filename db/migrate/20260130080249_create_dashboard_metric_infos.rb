class CreateDashboardMetricInfos < ActiveRecord::Migration[7.1]
  def change
    create_table :dashboard_metric_infos do |t|

      t.string :name, null: false
      t.string :ident, null: false
      t.string :category, null: false
      t.string :from
      t.float :default_weight
      t.float :default_threshold

      t.integer :dashboard_model_info_id
      t.timestamps
    end
  end
end
