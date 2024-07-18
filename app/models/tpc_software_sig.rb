# == Schema Information
#
# Table name: tpc_software_sigs
#
#  id               :bigint           not null, primary key
#  name             :string(255)      not null
#  value            :string(255)      not null
#  description      :string(255)      not null
#  subject_id       :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  committer_emails :string(1024)
#
class TpcSoftwareSig < ApplicationRecord

  belongs_to :subject
  has_many :tpc_software_selection_report
  has_many :tpc_software_output_report

  def self.get_eamil_list_by_short_code(short_code_list)
    mail_list = []
    subject_customization = SubjectCustomization.find_by(name: "OpenHarmony")
    if subject_customization.present?
      mail_list.concat(subject_customization.tpc_software_tag_mail.present? ? JSON.parse(subject_customization.tpc_software_tag_mail) : [])

      if short_code_list.any?
        tpc_software_sigs = TpcSoftwareSig.joins(:tpc_software_selection_report)
                                          .where("tpc_software_selection_reports.short_code IN (?)", short_code_list)
                                          .where("tpc_software_selection_reports.subject_id = ?", subject_customization.subject_id)
                                          .where("tpc_software_sigs.subject_id = ?", subject_customization.subject_id)
                                          .distinct
        tpc_software_sigs.each do |tpc_software_sig|
          mail_list.concat(tpc_software_sig.committer_emails.present? ? JSON.parse(tpc_software_sig.committer_emails) : [])
        end
      end
    end
    mail_list.uniq
  end
end
