# frozen_string_literal: true
class Notification::Email < NotificationService

  def execute
    return unless enabled?
      UserMailer.with(
        user: user,
        subject_name: subject_name,
        subject_url: subject_url,
        subscription_url: subscription_url,
        explore_url: explore_url,
        about_url: about_url
      ).send(notification_type).deliver_later
  end

  def enabled?
    !user.anonymous && user.email.present?
  end
end
