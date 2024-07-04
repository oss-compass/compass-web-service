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

end
