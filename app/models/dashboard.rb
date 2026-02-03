# == Schema Information
#
# Table name: dashboards
#
#  id              :bigint           not null, primary key
#  name            :string(255)      not null
#  dashboard_type  :string(255)
#  repo_urls       :string(255)
#  competitor_urls :string(255)
#  user_id         :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  identifier      :string(255)
#
class Dashboard < ApplicationRecord

  belongs_to :user
  has_many :dashboard_models, dependent: :destroy
  has_many :dashboard_metrics, dependent: :destroy

  # 允许在创建 Dashboard 时同时保存关联的 Model 和 Metric
  accepts_nested_attributes_for :dashboard_models, allow_destroy: true
  accepts_nested_attributes_for :dashboard_metrics, allow_destroy: true

  validates :identifier, presence: true, uniqueness: true

  # 创建前自动生成编码（如果前端没有传的话）
  before_validation :ensure_identifier_exists, on: :create
  # before_validation :generate_identifier, on: :create

  private

  # def generate_identifier
  #   self.identifier ||= SecureRandom.hex(4).upcase
  # end
  def ensure_identifier_exists
    return if identifier.present?
    # 生成一个唯一编码，例如：DASH-XXXXXX
    loop do
      self.identifier = "DASH-#{SecureRandom.hex(3).upcase}"
      break unless Dashboard.exists?(identifier: identifier)
    end
  end




end
