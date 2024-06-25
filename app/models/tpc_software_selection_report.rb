# == Schema Information
#
# Table name: tpc_software_selection_reports
#
#  id                       :bigint           not null, primary key
#  report_type              :integer          not null
#  name                     :string(255)      not null
#  tpc_software_sig_id      :integer          not null
#  release                  :string(255)      not null
#  release_time             :datetime         not null
#  manufacturer             :string(255)      not null
#  website_url              :string(255)      not null
#  code_url                 :string(255)      not null
#  programming_language     :string(255)      not null
#  code_count               :integer
#  license                  :string(255)
#  vulnerability_disclosure :string(255)
#  vulnerability_response   :string(255)
#  short_code               :string(255)      not null
#  subject_id               :integer          not null
#  user_id                  :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
class TpcSoftwareSelectionReport < ApplicationRecord

  belongs_to :tpc_software_sig
  belongs_to :subject
  has_many :tpc_software_report_metrics, as: :tpc_software_report, dependent: :destroy

end
