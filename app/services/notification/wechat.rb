# frozen_string_literal: true

class Notification::Wechat < NotificationService

  attr_accessor :login_bind

  def execute
    return unless enabled?

    send("#{notification_type}")
  end

  def subscription_update
    $wechat_client.send_template_msg(login_bind.uid, ENV['NOTIFICATION_WECHAT_SUBSCRIPTION_UPDATE_TEMPLATE_ID'], subject_url, '', {
      name: { value: subject_name },
      date: { value: params[:subject].status_updated_at.strftime("%Y-%m-%d") },
      status: { value: params[:subject].status }
    })
  end

  def submission
    $wechat_client.send_template_msg(login_bind.uid, ENV['NOTIFICATION_WECHAT_SUBMISSION_TEMPLATE_ID'], subscription_url, '', {
      name: { value: subject_name },
    })
  end

  def subscription_create
    $wechat_client.send_template_msg(login_bind.uid, ENV['NOTIFICATION_WECHAT_SUBSCRIPTION_CREATE_TEMPLATE_ID'], subject_url, '', {
      name: { value: subject_name },
    })
  end

  def subscription_delete
    $wechat_client.send_template_msg(login_bind.uid, ENV['NOTIFICATION_WECHAT_SUBSCRIPTION_DELETE_TEMPLATE_ID'], subscription_url, '', {
      name: { value: subject_name },
    })
  end

  def enabled?
    @login_bind = user.login_binds.find_by(provider: 'wechat')
    @login_bind.present?
  end
end
