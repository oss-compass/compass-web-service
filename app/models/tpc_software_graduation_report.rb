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
#  lifecycle_policy     :string(2000)
#  round_upstream       :string(255)
#  subject_id           :integer          not null
#  user_id              :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  license              :string(255)
#  code_count           :integer
#  is_incubation        :integer
#  oh_commit_sha        :string(500)
#
# Indexes
#
#  index_tpc_software_graduation_reports_on_short_code  (short_code) UNIQUE
#
class TpcSoftwareGraduationReport < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64
  alias_attribute :architecture_diagrams, :attachments

  belongs_to :tpc_software_sig
  belongs_to :subject
  belongs_to :user
  has_many :tpc_software_graduation_report_metrics, dependent: :destroy
  has_many :tpc_software_graduations, foreign_key: 'target_software_report_id'

  has_many_base64_attached :attachments

  CharacterSet = '0123456789abcdefghijklmnopqrstuvwxyz'

  def self.generate_short_code
    loop do
      short_code = "g#{Nanoid.generate(size: 7, alphabet: CharacterSet)}"
      break short_code unless TpcSoftwareGraduationReport.exists?(short_code: short_code)
    end
  end

end
