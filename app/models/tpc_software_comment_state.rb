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
  Member_Type_Legal = 2
  Member_Type_Compliance = 3
  Member_Types = [Member_Type_Committer, Member_Type_Sig_Lead, Member_Type_Legal, Member_Type_Compliance]

  Review_State_TPC_Await = "【待TPC SIG评审】"
  Review_State_TPC_Replenish = "【TPC：待补充信息】"
  Review_State_TPC_Review = "【TPC SIG评审中】"
  Review_State_Architecture_Await = "【待架构SIG评审】"
  Review_State_Architecture_Replenish = "【架构：待补充信息】"
  Review_State_Architecture_Pass = "【评审通过】"
  Review_States = [Review_State_TPC_Await, Review_State_TPC_Replenish, Review_State_TPC_Review,
                   Review_State_Architecture_Await, Review_State_Architecture_Replenish, Review_State_Architecture_Pass]

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
    legal_state  = get_state(tpc_software_id, tpc_software_type, Member_Type_Legal)
    compliance_state  = get_state(tpc_software_id, tpc_software_type, Member_Type_Compliance)

    states = [committer_state, sig_lead_state, legal_state, compliance_state]
    if states.all? { |item| item == State_Cancel }
      review_state = Review_State_TPC_Await
    elsif states.any? { |item| item == State_Reject }
      review_state = Review_State_TPC_Replenish
    elsif states.all? { |item| item == State_Accept }
      review_state = Review_State_Architecture_Await
    else
      review_state = Review_State_TPC_Review
    end
    review_state
  end

  def self.check_compliance_metric(metric_name)
    metric_name.start_with?("compliance") || metric_name == "ecologyPatentRisk"
  end


  def self.get_member_name(member_type)
    case member_type
    when Member_Type_Committer
      return "TPC垂域Committer"
    when Member_Type_Sig_Lead
      return "TPC SIG Leader"
    when Member_Type_Legal
      return "TPC法务专家"
    when Member_Type_Compliance
      return "TPC合规专家"
    end
  end
end
