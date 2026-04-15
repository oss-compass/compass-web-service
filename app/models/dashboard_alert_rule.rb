# == Schema Information
#
# Table name: dashboard_alert_rules
#
#  id                :bigint           not null, primary key
#  dashboard_id      :bigint
#  creator_id        :bigint
#  monitor_type      :integer          default(0)
#  target_repo       :string(255)
#  metric_key        :string(255)
#  metric_name       :string(255)
#  operator          :string(255)
#  operator_type     :string(255)
#  threshold         :decimal(15, 2)
#  level             :integer          default(1)
#  enabled           :boolean          default(TRUE)
#  notify_config     :string(255)
#  last_triggered_at :datetime
#  description       :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_dashboard_alert_rules_on_creator_id    (creator_id)
#  index_dashboard_alert_rules_on_dashboard_id  (dashboard_id)
#
class DashboardAlertRule < ApplicationRecord

end
