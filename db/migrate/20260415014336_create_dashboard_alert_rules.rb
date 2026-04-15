class CreateDashboardAlertRules < ActiveRecord::Migration[7.1]
  def change
    create_table :dashboard_alert_rules do |t|
      # 关联
      t.references :dashboard, comment: '所属看板'
      t.references :creator, foreign_key: { to_table: :users }, comment: '创建人'

      # 监控类型
      t.integer :monitor_type, default: 0, comment: '监控类型: 0-社区, 1-仓库'

      # 监控目标
      t.string :target_repo, comment: '监控的仓库URL（仓库类型时填写）'
      # 监控指标
      t.string :metric_key, comment: '指标标识'
      t.string :metric_name, comment: '指标名称'

      # 预警条件
      t.string :operator, comment: '比较运算符: >, >=, <, <=, ==, !='
      t.string :operator_type, comment: '绝对值，百分比'
      t.decimal :threshold, precision: 15, scale: 2, comment: '预警阈值'

      # 预警级别
      t.integer :level, default: 1, comment: '级别: 0-提示(info), 1-警告(warning), 2-严重(critical)'

      # 状态
      t.boolean :enabled, default: true, comment: '是否启用'

      # 通知配置
      t.string :notify_config,  comment: '通知配置: {channels: ["email"], recipients: [...]}'

      t.datetime :last_triggered_at, comment: '上次触发时间'

      # # 统计
      # t.integer :trigger_count, default: 0, comment: '触发次数'

      t.text :description, comment: '规则描述'
      t.timestamps
    end
  end
end
