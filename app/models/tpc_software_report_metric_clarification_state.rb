# == Schema Information
#
# Table name: tpc_software_report_metric_clarification_states
#
#  id                            :bigint           not null, primary key
#  tpc_software_report_metric_id :integer          not null
#  user_id                       :integer          not null
#  subject_id                    :integer          not null
#  metric_name                   :string(255)      not null
#  state                         :integer          not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
class TpcSoftwareReportMetricClarificationState < ApplicationRecord

  belongs_to :tpc_software_report_metric
  belongs_to :subject

  State_Accept = 1
  State_Reject = 0


end
