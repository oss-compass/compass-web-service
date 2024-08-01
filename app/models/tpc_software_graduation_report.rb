# == Schema Information
#
# Table name: tpc_software_graduation_reports
#
#  id                   :bigint           not null, primary key
#  short_code           :string(255)      not null
#  name                 :string(255)
#  tpc_software_sig_id  :integer
#  code_url             :string(255)
#  upstream_code_url    :string(255)
#  programming_language :string(255)      not null
#  adaptation_method    :string(255)      not null
#  lifecycle_policy     :string(500)      not null
#  subject_id           :integer          not null
#  user_id              :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_tpc_software_graduation_reports_on_short_code  (short_code) UNIQUE
#
class TpcSoftwareGraduationReport < ApplicationRecord

  belongs_to :tpc_software_sig
  belongs_to :subject
  belongs_to :user
  has_many :tpc_software_graduation_report_metrics, dependent: :destroy

  CharacterSet = '0123456789abcdefghijklmnopqrstuvwxyz'

  def self.generate_short_code
    loop do
      short_code = "g#{Nanoid.generate(size: 7, alphabet: CharacterSet)}"
      break short_code unless TpcSoftwareGraduationReport.exists?(short_code: short_code)
    end
  end

end
