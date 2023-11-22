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
#  language                   :string(255)      default("en")
#  role_level                 :integer          default(0), not null
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

  alias_attribute :metric_models, :lab_models
  alias_attribute :invitations, :lab_model_invitations

  has_many :login_binds, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :lab_models, dependent: :destroy
  has_many :subject_access_levels, dependent: :destroy
  has_many :lab_model_invitations

  validate :check_email_change_limit
  validates :encrypted_password, presence: true
  after_initialize :set_default_language, if: :new_record?

  after_update :send_email_verification, if: -> { saved_changes.keys.include?('email') }

  ANONYMOUS_EMAIL_SUFFIX = '@user.anonymous.oss-compass.org'
  NORMAL_ROLE = 0

  def email_verified?
    email_verification_token.nil?
  end

  def is_admin?
    role_level.to_i > NORMAL_ROLE
  end

  def verify_email(token)
    if !email_verification_expired? && email_verification_token == token
      self.email_verification_token = nil
      self.anonymous = false
      save
      true
    else
      false
    end
  end

  def avatar_url
    login_binds.first.avatar_url_after_reviewed
  end

  def send_email_invitation(email, model, permission)
    return unless check_send_email_limit(send_email_invite_limit_key(email))

    email_invitation_token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless LabModelInvitation.exists?(token: random_token)
    end

    extra = JSON.dump(permission: permission)

    self.invitations.create!(lab_model: model, email: email, token: email_invitation_token, extra: extra)

  end

  def send_email_verification
    return unless check_send_email_limit(send_email_limit_key)

    generate_email_verification_token
    UserMailer.with(
      user: self,
      host: ENV['DEFAULT_HOST'],
      locale: I18n.locale
    ).email_verification.deliver_later
    true
  end

  def my_member_permission_of(model)
    policy = ::Pundit.policy(self, model)
    {
      can_read: policy.read?,
      can_update: policy.update?,
      can_execute: policy.execute?,
      can_destroy: policy.destroy?
    }
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

  def bind_omniauth(auth)
    provider = auth.provider
    uid = auth.uid
    user = LoginBind.find_by(provider: provider, uid: uid)&.user
    return user if user.present?

    login_binds.find_or_create_by(provider: provider) do |login_bind|
      login_bind.provider_id = LoginBind::PROVIDER_ID_MAP[auth.provider]

      login_bind.uid = uid
      login_bind.account = auth.info.name
      login_bind.nickname = auth.info.nickname
      login_bind.avatar_url = auth.info.image
    end
  end

  def self.from_omniauth(auth)
    provider = auth.provider
    uid = auth.uid
    user = LoginBind.find_by(provider: provider, uid: uid)&.user
    return user if user.present?

    account = auth.info.name
    nickname = auth.info.nickname
    avatar_url = auth.info.image
    provider_id = LoginBind::PROVIDER_ID_MAP[auth.provider]

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

  def has_privilege_to?(label, level)
    subject = Subject.find_by(label: label, level: level)
    return false if subject.blank?
    subject_access_levels.find_by(subject: subject)&.access_level == SubjectAccessLevel::PRIVILEGED_LEVEL
  end

  def lab_models_has_participated_in
    LabModel
      .joins(:lab_model_members)
      .where(lab_model_members: { user_id: id })
      .order('updated_at desc')
      .order(:name)
  end

  def self.gen_anonymous_email(provider, uid)
    "#{provider}_#{uid}#{ANONYMOUS_EMAIL_SUFFIX}"
  end

  private

  def email_change_limit_key
    "user:email_change_limit:#{id}"
  end

  def send_email_limit_key
    "user:send_email_limit:#{id}:#{email}"
  end

  def send_email_invite_limit_key(email)
    "user:send_email_invite_limit:#{id}:#{email}"
  end

  def check_send_email_limit(cache_key)
    count = Rails.cache.increment(cache_key)
    Rails.cache.write(cache_key, 1, expires_in: 1.day, raw: true) if count == 1
    max_count = ENV.fetch('MAX_SEND_EMAIL_COUNT') { 3 }.to_i
    if count > max_count
      case cache_key
      when send_email_limit_key
        errors.add(:base, I18n.t("users.send_email_limit", count: max_count))
      else
        errors.add(:base, I18n.t("users.send_email_limit", count: max_count))
      end
      return false
    end
    true
  end

  def check_email_change_limit
    return if new_record?

    return unless email_changed?

    count = Rails.cache.increment(email_change_limit_key)
    Rails.cache.write(email_change_limit_key, 1, expires_in: 1.day, raw: true) if count == 1
    max_count = ENV.fetch('MAX_EMAIL_CHANGE_COUNT') { 3 }.to_i
    errors.add(:base, I18n.t("users.email_change_limit", count: max_count)) if count > max_count
  end

  def set_default_language
    self.language = I18n.locale
    self.language ||= I18n.default_locale
  end
end
