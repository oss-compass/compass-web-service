# frozen_string_literal: true

class Notification::Slack < NotificationService
  attr_accessor :login_bind

  def execute
    return unless enabled?

    uid = login_bind.uid
    client = Slack::Web::Client.new
    client.chat_postMessage(
      channel: uid,
      text: send("#{notification_type}_content"),
      mrkdwn: true
    )
  end

  def subscription_update_content
    I18n.t('notification.slack.subscription_update_content', locale: user.language, user_name: user.name, subject_name: subject_name, subject_url: subject_url, subscription_url: subscription_url, explore_url: explore_url, about_url: about_url)
  end

  def submission_content
    I18n.t('notification.slack.submission_content', locale: user.language, user_name: user.name, subject_name: subject_name, subject_url: subject_url, subscription_url: subscription_url, explore_url: explore_url, about_url: about_url)
  end

  def subscription_create_content
    I18n.t('notification.slack.subscription_create_content', locale: user.language, user_name: user.name, subject_name: subject_name, subject_url: subject_url, subscription_url: subscription_url, explore_url: explore_url, about_url: about_url)
  end

  def subscription_delete_content
    I18n.t('notification.slack.subscription_delete_content', locale: user.language, user_name: user.name, subject_name: subject_name, subject_url: subject_url, subscription_url: subscription_url, explore_url: explore_url, about_url: about_url)
  end

  def enabled?
    @login_bind = user.login_binds.find_by(provider: 'slack')
    @login_bind.present?
  end
end
