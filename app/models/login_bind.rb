# == Schema Information
#
# Table name: login_binds
#
#  id          :bigint           not null, primary key
#  user_id     :bigint           not null
#  provider    :string(255)      not null
#  account     :string(255)      not null
#  nickname    :string(255)
#  avatar_url  :string(255)
#  uid         :string(255)
#  provider_id :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_login_binds_on_account              (account)
#  index_login_binds_on_provider             (provider)
#  index_login_binds_on_uid_and_provider_id  (uid,provider_id) UNIQUE
#  index_login_binds_on_user_id              (user_id)
#
class LoginBind < ApplicationRecord
  belongs_to :user

  scope :current_host, -> { where(provider_id: [ENV['GITHUB_CLIENT_ID'], ENV['GITEE_CLIENT_ID']]) }

  class << self
    def current_host_nickname(user, provider)
      user.login_binds.current_host.find_by(provider: provider)&.nickname
    end
  end
end
