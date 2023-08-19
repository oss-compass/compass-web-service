# == Schema Information
#
# Table name: lab_model_invitations
#
#  id           :bigint           not null, primary key
#  email        :string(255)      not null
#  token        :string(255)      not null
#  lab_model_id :integer          not null
#  status       :integer          default("pending"), not null
#  user_id      :integer          not null
#  extra        :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_lab_model_invitations_on_lab_model_id  (lab_model_id)
#
class LabModelInvitation < ApplicationRecord
  alias_attribute :sent_at, :created_at

  belongs_to :lab_model
  belongs_to :user


  validates :email, presence: true
  validates :token, presence: true
  validates :status, presence: true

  enum status: {
    pending: 0,
    finished: 1,
    expired: 2,
    cancel: 3
  }

  after_commit :send_invite_email, on: :create

  def send_invite_email
    UserMailer.with(
      user: user,
      host: ENV['DEFAULT_HOST'],
      locale: I18n.locale,
      model: lab_model,
      token: token,
      email: email
    ).email_invitation.deliver_later
  end

  def expired?
    updated_at < 72.hours.ago
  end

  def permission
    JSON.load(extra)['permission'] rescue LabModelMember::Read
  end

  def can_read
    permission & LabModelMember::Read == LabModelMember::Read
  end

  def can_update
    permission & LabModelMember::Update == LabModelMember::Update
  end

  def can_execute
    permission & LabModelMember::Execute == LabModelMember::Execute
  end

  def verify_and_finish!(user, token)
    return false unless pending?
    if !expired? && token == self.token
      if lab_model.has_member?(user)
        false
      else
        ActiveRecord::Base.transaction do
          lab_model.members.create!(user: user, permission: permission)
          self.update!(status: :finished)
        end
      end
    else
      self.update(status: :expired)
      false
    end
  end
end
