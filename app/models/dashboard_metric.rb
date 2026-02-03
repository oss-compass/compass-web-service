# == Schema Information
#
# Table name: dashboard_metrics
#
#  id                          :bigint           not null, primary key
#  name                        :string(255)      not null
#  from_model                  :boolean          default(FALSE)
#  hidden                      :boolean          default(FALSE)
#  dashboard_model_id          :integer
#  dashboard_id                :integer
#  dashboard_metric_info_id    :integer
#  dashboard_metric_info_ident :string(255)
#  dashboard_model_info_ident  :string(255)
#  sort                        :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
class DashboardMetric < ApplicationRecord
end
