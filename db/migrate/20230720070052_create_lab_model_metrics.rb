class CreateLabModelMetrics < ActiveRecord::Migration[7.0]
  def change
    create_table :lab_model_metrics do |t|
      t.integer :lab_metric_id, null: false
      t.integer :lab_model_version_id, null: false
      t.float :weight
      t.float :threshold

      t.timestamps
    end

    add_index :lab_model_metrics, [:lab_model_version_id, :lab_metric_id], name: "index_metrics_on_v_m"
  end
end
