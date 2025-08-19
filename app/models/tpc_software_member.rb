# == Schema Information
#
# Table name: tpc_software_members
#
#  id                  :bigint           not null, primary key
#  user_id             :integer
#  member_type         :integer          not null
#  name                :string(255)
#  company             :string(255)
#  email               :string(255)
#  github_account      :string(255)
#  gitee_account       :string(255)
#  tpc_software_sig_id :integer
#  description         :string(255)
#  role_level          :integer          default(0)
#  subject_id          :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class TpcSoftwareMember < ApplicationRecord

  belongs_to :tpc_software_sig
  belongs_to :subject

  Member_Type_Normal = 0
  Member_Type_Sig_Committer = 1
  Member_Type_TAG = 2
  Member_Type_Sig_Lead = 3
  Member_Type_Legal = 4
  Member_Type_Compliance = 5
  Member_Type_QA = 6
  Member_Type_Community_Collaboration_WG = 7

  Role_Level_Normal = 0
  Role_Level_Email = 1
  Role_Level_Approval = 2

  def self.get_email_notify_list(short_code, report_type)
    email_list = []
    subject_customization = SubjectCustomization.find_by(name: "OpenHarmony")
    return email_list if subject_customization.nil?
    report = nil
    case report_type
    when TpcSoftwareMetricServer::Report_Type_Selection
      report = TpcSoftwareSelectionReport.find_by(short_code: short_code, subject_id: subject_customization.subject_id)
    when TpcSoftwareMetricServer::Report_Type_Graduation
      report = TpcSoftwareGraduationReport.find_by(short_code: short_code, subject_id: subject_customization.subject_id)
    end

    return email_list if report.nil?
    tpc_software_member_list = TpcSoftwareMember.where("tpc_software_sig_id IS NULL OR tpc_software_sig_id = ?", report.tpc_software_sig_id)
                                                .where("role_level >= ?", Role_Level_Email)
                                                .where(subject_id: subject_customization.subject_id)
    email_list = tpc_software_member_list.map do |tpc_software_member|
      tpc_software_member.email
    end
    email_list.uniq
  end

  def self.check_sig_lead_permission?(current_user)
    permission = false
    subject_customization = SubjectCustomization.find_by(name: "OpenHarmony")
    return permission if subject_customization.nil?
    tpc_software_member = TpcSoftwareMember.where(user_id: current_user.id)
                                           .where(member_type: Member_Type_Sig_Lead)
                                           .where("role_level >= ?", Role_Level_Approval)
                                           .where(subject_id: subject_customization.subject_id)
                                           .take
    return tpc_software_member.present?
  end

  def self.check_committer_permission?(sig_id, current_user)
    permission = false
    subject_customization = SubjectCustomization.find_by(name: "OpenHarmony")
    return permission if subject_customization.nil?
    tpc_software_member = TpcSoftwareMember.where(user_id: current_user.id)
                                           .where(tpc_software_sig_id: sig_id)
                                           .where(member_type: Member_Type_Sig_Committer)
                                           .where("role_level >= ?", Role_Level_Approval)
                                           .where(subject_id: subject_customization.subject_id)
                                           .take
    return tpc_software_member.present?
  end

  def self.check_legal_permission?(current_user)
    permission = false
    subject_customization = SubjectCustomization.find_by(name: "OpenHarmony")
    return permission if subject_customization.nil?
    tpc_software_member = TpcSoftwareMember.where(user_id: current_user.id)
                                           .where(member_type: Member_Type_Legal)
                                           .where("role_level >= ?", Role_Level_Approval)
                                           .where(subject_id: subject_customization.subject_id)
                                           .take
    return tpc_software_member.present?
  end

  def self.check_compliance_permission?(current_user)
    permission = false
    subject_customization = SubjectCustomization.find_by(name: "OpenHarmony")
    return permission if subject_customization.nil?
    tpc_software_member = TpcSoftwareMember.where(user_id: current_user.id)
                                           .where(member_type: Member_Type_Compliance)
                                           .where("role_level >= ?", Role_Level_Approval)
                                           .where(subject_id: subject_customization.subject_id)
                                           .take
    return tpc_software_member.present?
  end

  def self.get_committer_list(current_user, subject_id)
    committer_list = TpcSoftwareMember.where(user_id: current_user.id)
                                           .where(member_type: Member_Type_Sig_Committer)
                                           .where("role_level >= ?", Role_Level_Approval)
                                           .where(subject_id: subject_id)
    return committer_list
  end

  def self.check_qa_permission?(current_user)
    permission = false
    subject_customization = SubjectCustomization.find_by(name: "OpenHarmony")
    return permission if subject_customization.nil?
    tpc_software_member = TpcSoftwareMember.where(user_id: current_user.id)
                                           .where(member_type: Member_Type_QA)
                                           .where("role_level >= ?", Role_Level_Approval)
                                           .where(subject_id: subject_customization.subject_id)
                                           .take
    return tpc_software_member.present?
  end

  def self.check_wg_permission?(current_user)
    permission = false
    subject_customization = SubjectCustomization.find_by(name: "OpenHarmony")
    return permission if subject_customization.nil?
    tpc_software_member = TpcSoftwareMember.where(user_id: current_user.id)
                                           .where(member_type: Member_Type_Community_Collaboration_WG)
                                           .where("role_level >= ?", Role_Level_Approval)
                                           .where(subject_id: subject_customization.subject_id)
                                           .take
    return tpc_software_member.present?
    end

end
