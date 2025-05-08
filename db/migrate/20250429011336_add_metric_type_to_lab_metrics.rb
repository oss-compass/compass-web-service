class AddMetricTypeToLabMetrics < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_metrics, :metric_type, :integer, default: 0

  end
end
