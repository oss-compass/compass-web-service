# == Schema Information
#
# Table name: subscriptions
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  subject_id :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_subscriptions_on_user_id_and_subject_id  (user_id,subject_id) UNIQUE
#
class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :subject
  delegate :label, :level, :status, :count, :status_updated_at, to: :subject, allow_nil: true

  attr_accessor :skip_notify_subscription

  after_create :notify_subscription, unless: :skip_notify_subscription
  after_destroy :notify_unsubscription

  private

  def notify_subscription
    NotificationService.new(user, NotificationService::SUBSCRIPTION_CREATE, { subject: subject }).execute
  end

  def notify_unsubscription
    NotificationService.new(user, NotificationService::SUBSCRIPTION_DELETE, { subject: subject }).execute
  end
end
