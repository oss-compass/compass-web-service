# == Schema Information
#
# Table name: tpc_software_output_reports
#
#  id                               :bigint           not null, primary key
#  tpc_software_selection_id        :integer          not null
#  tpc_software_selection_order_num :string(255)      not null
#  name                             :string(255)      not null
#  tpc_software_sig_id              :integer          not null
#  repo_url                         :string(255)      not null
#  reason                           :string(255)      not null
#  subject_id                       :integer          not null
#  user_id                          :integer          not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#
class TpcSoftwareOutputReport < ApplicationRecord

  belongs_to :tpc_software_sig
  belongs_to :subject
  belongs_to :tpc_software_selection
  has_many :tpc_software_report_metrics, as: :tpc_software_report, dependent: :destroy
  has_many :tpc_software_outputs, dependent: :destroy

end
