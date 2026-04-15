# == Schema Information
#
# Table name: dashboard_alert_records
#
#  id                      :bigint           not null, primary key
#  dashboard_alert_rule_id :bigint
#  dashboard_id            :bigint
#  triggered_at            :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_dashboard_alert_records_on_dashboard_alert_rule_id  (dashboard_alert_rule_id)
#  index_dashboard_alert_records_on_dashboard_id             (dashboard_id)
#
class DashboardAlertRecord < ApplicationRecord

  belongs_to :alert_rule
  belongs_to :dashboard

end
