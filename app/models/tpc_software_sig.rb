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
  has_many :tpc_software_selection_reports
  has_many :tpc_software_graduation_reports
  has_many :tpc_software_members

  def sig_committer
    TpcSoftwareMember.where(tpc_software_sig_id: id)
                     .where(member_type: TpcSoftwareMember::Member_Type_Sig_Committer)
                     .where.not(gitee_account: nil)

  end

  def adaptation_committer
    TpcSoftwareMember.where(tpc_software_sig_id: id)
                     .where(member_type: TpcSoftwareMember::Member_Type_Sig_Committer)
                     .where.not(gitcode_account: nil)

  end

end
