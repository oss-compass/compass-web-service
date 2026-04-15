class AddTimeRangeToDashboardAlertRules < ActiveRecord::Migration[7.1]
  def change
    add_column :dashboard_alert_rules, :time_range, :integer
  end
end
