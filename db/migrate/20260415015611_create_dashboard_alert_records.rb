class CreateDashboardAlertRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :dashboard_alert_records do |t|
      t.references :dashboard_alert_rule, foreign_key: true, comment: '关联规则'

      t.references :dashboard, foreign_key: true, comment: '所属看板'

      t.datetime :triggered_at, comment: '触发时间'
      t.timestamps
    end
  end
end
