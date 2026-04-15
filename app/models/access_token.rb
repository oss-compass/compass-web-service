# == Schema Information
#
# Table name: access_tokens
#
#  id         :bigint           not null, primary key
#  token      :string(255)      not null
#  user_id    :integer          not null
#  name       :string(255)
#  type       :integer
#  expires_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_access_tokens_on_expires_at  (expires_at)
#  index_access_tokens_on_token       (token) UNIQUE
#  index_access_tokens_on_user_id     (user_id)
#

class AccessToken < ApplicationRecord
  belongs_to :user
  validates :token, presence: true, uniqueness: true
  validates :user_id, presence: true
  before_validation :generate_token, on: :create
  self.inheritance_column = :_type_disabled

  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def expired?
    expires_at.present? && Time.current > expires_at
  end



  private

  def generate_token
    self.token ||= SecureRandom.hex(20)
  end
end
