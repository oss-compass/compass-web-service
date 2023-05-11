# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                         :bigint           not null, primary key
#  email                      :string(255)      default(""), not null
#  encrypted_password         :string(255)      default(""), not null
#  reset_password_token       :string(255)
#  reset_password_sent_at     :datetime
#  sign_in_count              :integer          default(0), not null
#  current_sign_in_at         :datetime
#  last_sign_in_at            :datetime
#  current_sign_in_ip         :string(255)
#  last_sign_in_ip            :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  anonymous                  :boolean          default(FALSE)
#  email_verification_token   :string(255)
#  email_verification_sent_at :datetime
#  name                       :string(255)
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist

  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :trackable,
         :jwt_authenticatable, :omniauthable, jwt_revocation_strategy: self

  has_many :login_binds, dependent: :destroy

  after_update :send_email_verification, if: -> { saved_changes.keys.include?('email') }

  ANONYMOUS_EMAIL_SUFFIX = '@user.anonymous.oss-compass.org'

  def email_verified?
    email_verification_token.nil?
  end

  def verify_email(token)
    if !email_verification_expired? && email_verification_token == token
      self.email_verification_token = nil
      save
      true
    else
      false
    end
  end

  def send_email_verification
    generate_email_verification_token
    UserMailer.with(
      user: self,
      host: ENV['DEFAULT_HOST'],
      locale: I18n.locale
    ).email_verification.deliver_later
    true
  end

  def generate_email_verification_token
    self.email_verification_token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless User.exists?(email_verification_token: random_token)
    end
    self.email_verification_sent_at = Time.current
    save
  end

  def email_verification_expired?
    email_verification_sent_at < 72.hours.ago
  end

  def self.from_omniauth(auth)
    provider = auth.provider
    uid = auth.uid
    user = LoginBind.find_by(provider: provider, uid: uid)&.user
    return user if user.present?

    account = auth.info.name
    nickname = auth.info.nickname
    avatar_url = auth.info.image
    provider_id = auth.provider == 'github' ? ENV['GITHUB_CLIENT_ID'] : ENV['GITEE_CLIENT_ID']

    anonymous = auth.info.email.blank?
    email = anonymous ? gen_anonymous_email(provider, uid) : auth.info.email

    user = User.find_by(email: email)

    if user.present?
      # check if user has bind provider, and uid is not same
      if user.login_binds.exists?(provider: provider)
        email = gen_anonymous_email(provider, uid)
        anonymous = true
      else
        user.login_binds.find_or_create_by(uid: uid, provider_id: provider_id) do |login_bind|
          login_bind.provider = provider
          login_bind.account = account
          login_bind.nickname = nickname
          login_bind.avatar_url = avatar_url
        end
        return user
      end
    end

    ActiveRecord::Base.transaction do
      user = User.create!(name: account, email: email, password: Devise.friendly_token[0, 20], anonymous: anonymous)
      user.login_binds.create!(provider: provider, uid: uid, account: account, nickname: nickname, avatar_url: avatar_url, provider_id: provider_id)
    end
    user
  end

  def self.gen_anonymous_email(provider, uid)
    "#{provider}_#{uid}#{ANONYMOUS_EMAIL_SUFFIX}"
  end
end
