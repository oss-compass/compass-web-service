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

  def self.check_permission?(sig_id, current_user)
    return true if current_user&.is_admin?

    permission_mail_list = []

    subject_customization = SubjectCustomization.find_by(name: "OpenHarmony")
    if subject_customization.present?
      permission_mail_list.concat(subject_customization.tpc_software_tag_mail.present? ? JSON.parse(subject_customization.tpc_software_tag_mail) : [])
    end
    tpc_software_sig = TpcSoftwareSig.find_by(id: sig_id)
    if tpc_software_sig.present?
      permission_mail_list.concat(tpc_software_sig.committer_emails.present? ? JSON.parse(tpc_software_sig.committer_emails) : [])
    end

    permission_mail_list.include?(current_user.email)
  end


end
