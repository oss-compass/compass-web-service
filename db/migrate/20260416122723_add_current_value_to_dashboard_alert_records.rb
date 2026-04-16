class AddCurrentValueToDashboardAlertRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :dashboard_alert_records, :current_value, :decimal, precision: 10, scale: 2
  end
end
