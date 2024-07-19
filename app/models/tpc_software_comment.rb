# == Schema Information
#
# Table name: tpc_software_comments
#
#  id                :bigint           not null, primary key
#  tpc_software_id   :integer          not null
#  user_id           :integer          not null
#  subject_id        :integer          not null
#  metric_name       :string(255)      not null
#  content           :string(5000)     not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  tpc_software_type :string(255)      default("TpcSoftwareReportMetric"), not null
#
class TpcSoftwareComment < ApplicationRecord

  belongs_to :tpc_software, polymorphic: true
  belongs_to :subject

  Type_Selection = 'TpcSoftwareSelection'
  Type_Report_Metric = 'TpcSoftwareReportMetric'

  Metric_Name_Selection = 'selection'

end
