class AddExtraToLabMetrics < ActiveRecord::Migration[7.0]
  def change
    add_column :lab_metrics, :extra, :text, default: '{}'
  end
end
