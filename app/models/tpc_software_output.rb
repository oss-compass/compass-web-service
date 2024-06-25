# == Schema Information
#
# Table name: tpc_software_outputs
#
#  id                            :bigint           not null, primary key
#  tpc_software_output_report_id :integer          not null
#  name                          :string(255)      not null
#  repo_url                      :string(255)      not null
#  tpc_audit_status              :integer
#  tpc_audit_reason              :string(255)
#  tpc_audit_user_id             :integer
#  architecture_audit_status     :integer
#  architecture_audit_reason     :string(255)
#  architecture_audit_user_id    :integer
#  qa_audit_status               :integer
#  qa_audit_reason               :string(255)
#  qa_audit_user_id              :integer
#  order_num                     :string(255)      not null
#  status                        :integer          not null
#  subject_id                    :integer          not null
#  user_id                       :integer          not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
class TpcSoftwareOutput < ApplicationRecord

  belongs_to :subject
  belongs_to :tpc_software_output_report
  belongs_to :user

  Status_Apply = 0
  Status_Tpc_Audit = 1
  Status_Architecture_Audit = 2
  Status_Qa_Audit = 3

  Audit_Status_Reject = 0
  Audit_Status_Pass = 1

end
