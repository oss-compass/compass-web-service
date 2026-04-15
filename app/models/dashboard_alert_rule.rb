# == Schema Information
#
# Table name: dashboard_alert_rules
#
#  id                :bigint           not null, primary key
#  dashboard_id      :bigint
#  creator_id        :bigint
#  monitor_type      :integer          default("community")
#  target_repo       :string(255)
#  metric_key        :string(255)
#  metric_name       :string(255)
#  operator          :string(255)
#  operator_type     :string(255)
#  threshold         :decimal(15, 2)
#  level             :integer          default("warning")
#  enabled           :boolean          default(TRUE)
#  notify_config     :string(255)
#  last_triggered_at :datetime
#  description       :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  time_range        :integer
#
# Indexes
#
#  index_dashboard_alert_rules_on_creator_id    (creator_id)
#  index_dashboard_alert_rules_on_dashboard_id  (dashboard_id)
#
class DashboardAlertRule < ApplicationRecord
  belongs_to :dashboard
  belongs_to :creator, class_name: 'User'
  has_many :alert_records, dependent: :destroy

  # 监控类型
  enum monitor_type: { community: 0, repository: 1 }

  # 预警级别
  enum level: { info: 0, warning: 1, critical: 2 }

  # 支持的运算符
  OPERATORS = %w[> >= < <= == ].freeze

  # validates :metric_key, presence: true
  # validates :operator, inclusion: { in: OPERATORS }
  # validates :threshold, numericality: true
  # validates :target_repo, presence: true, if: :repository?

  # 指标定义（社区）
  COMMUNITY_METRICS = {
    'new_issues_count' => { name: '新建 Issue 数量', unit: '个' },
    'issue_resolution_rate' => { name: 'Issue 解决百分比', unit: '%' },
    'unresponsive_issues_count' => { name: '未响应 Issues 数量', unit: '个' },
    'avg_response_time' => { name: '平均响应时间', unit: '天' }
  }.freeze

  # 指标定义（仓库）
  REPOSITORY_METRICS = {
    'issues_total_count' => { name: 'Issue 总数', unit: '个' },
    'issues_open_count' => { name: '打开 Issue 数量', unit: '个' },
    'issue_close_rate' => { name: 'Issue 闭环率', unit: '%' },
    'avg_close_time' => { name: '平均闭环时长', unit: '天' },
    'avg_first_response_time' => { name: 'Issue 首次响应时间', unit: '天' },
    'unresponsive_issues_count' => { name: '未响应 Issue 数量', unit: '个' }
  }.freeze

  # 检查是否满足预警条件
  def check_condition(actual_value)

    case operator
    when '>' then actual_value > threshold
    when '>=' then actual_value >= threshold
    when '<' then actual_value < threshold
    when '<=' then actual_value <= threshold
    when '==' then actual_value == threshold
    else false
    end
  end

  # 触发预警
  def trigger!(actual_value)

    transaction do
      record = alert_records.create!(
        dashboard: dashboard,
        actual_value: actual_value,
        threshold: threshold,
        operator: operator,
        level: level
      )

      update!(
        last_triggered_at: Time.current,

      )
      # 发送通知（异步）
      # AlertNotifyJob.perform_later(record)
      record
    end
  end

  # 指标选项（用于前端下拉）
  def self.metric_options(monitor_type)
    metrics = monitor_type == 'community' ? COMMUNITY_METRICS : REPOSITORY_METRICS
    metrics.map { |key, info| { key: key, name: info[:name], unit: info[:unit] } }
  end

  scope :enabled, -> { where(enabled: true) }
  scope :for_community, -> { where(monitor_type: :community) }
  scope :for_repository, -> { where(monitor_type: :repository) }
end
