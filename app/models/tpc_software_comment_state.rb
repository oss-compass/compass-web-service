# == Schema Information
#
# Table name: tpc_software_comment_states
#
#  id                :bigint           not null, primary key
#  tpc_software_id   :integer          not null
#  user_id           :integer          not null
#  subject_id        :integer          not null
#  metric_name       :string(255)      not null
#  state             :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  member_type       :integer          default(0)
#  tpc_software_type :string(255)      default("TpcSoftwareReportMetric"), not null
#
class TpcSoftwareCommentState < ApplicationRecord

  belongs_to :tpc_software, polymorphic: true
  belongs_to :subject

  Type_Selection = 'TpcSoftwareSelection'
  Type_Report_Metric = 'TpcSoftwareReportMetric'

  Metric_Name_Selection = 'selection'

  State_Accept = 1
  State_Cancel = 0
  State_Reject = -1
  States = [State_Accept, State_Cancel, State_Reject]

  Member_Type_Committer = 0
  Member_Type_Sig_Lead = 1
  Member_Types = [Member_Type_Committer, Member_Type_Sig_Lead]

  Review_State_TPC_Await = "【待TPC SIG评审】"
  Review_State_TPC_Replenish = "【TPC：待补充信息】"
  Review_State_TPC_Review = "【TPC SIG评审中】"
  Review_State_Architecture_Await = "【待架构SIG评审】"
  Review_State_Architecture_Replenish = "【架构：待补充信息】"
  Review_State_Architecture_Pass = "【评审通过】"
  Review_States = [Review_State_TPC_Await, Review_State_TPC_Replenish, Review_State_TPC_Review,
                   Review_State_Architecture_Await, Review_State_Architecture_Replenish, Review_State_Architecture_Pass]

  def self.check_committer_permission?(sig_id, current_user)
    return true if current_user&.is_admin?

    permission_mail_list = []
    tpc_software_sig = TpcSoftwareSig.find_by(id: sig_id)
    if tpc_software_sig.present?
      permission_mail_list.concat(tpc_software_sig.committer_emails.present? ? JSON.parse(tpc_software_sig.committer_emails) : [])
    end
    permission_mail_list.include?(current_user.email)
  end

  def self.check_committer_permission_by_selection?(selection_report_ids, current_user)
    committer_permission_list = []
    selection_report_list = TpcSoftwareSelectionReport.where(id: selection_report_ids)
    selection_report_list.each do |report|
      committer_permission = check_committer_permission?(report.tpc_software_sig_id, current_user)
      committer_permission_list.append(committer_permission)
    end
    committer_permission_list.include?(true)
  end

  def self.check_sig_lead_permission?(current_user)
    return true if current_user&.is_admin?

    permission_mail_list = []
    subject_customization = SubjectCustomization.find_by(name: "OpenHarmony")
    if subject_customization.present?
      permission_mail_list.concat(subject_customization.tpc_software_tag_mail.present? ? JSON.parse(subject_customization.tpc_software_tag_mail) : [])
    end
    permission_mail_list.include?(current_user.email)
  end


  def self.get_state(tpc_software_id, tpc_software_type, member_type)
    comment_state_list = TpcSoftwareCommentState.where(tpc_software_id: tpc_software_id)
                                       .where(tpc_software_type: tpc_software_type)
                                       .where(member_type: member_type)
    return State_Cancel if comment_state_list.length == 0
    return State_Reject if comment_state_list.any? { |item| item[:state] == -1 }
    return State_Accept if comment_state_list.all? { |item| item[:state] == 1 }
  end


  def self.get_review_state(tpc_software_id, tpc_software_type)
    committer_state  = get_state(tpc_software_id, tpc_software_type, Member_Type_Committer)
    sig_lead_state  = get_state(tpc_software_id, tpc_software_type, Member_Type_Sig_Lead)
    states = [committer_state, sig_lead_state]
    review_state = Review_State_TPC_Await
    if states.all? { |item| item == 0 }
      review_state = Review_State_TPC_Await
    elsif states.any? { |item| item == -1 }
      review_state = Review_State_TPC_Replenish
    elsif states.all? { |item| item == 1 }
      review_state = Review_State_Architecture_Await
    else
      review_state = Review_State_TPC_Review
    end
    review_state
  end

end