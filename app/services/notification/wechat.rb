# frozen_string_literal: true

class Notification::Wechat < NotificationService

  attr_accessor :login_bind

  def execute
    return unless enabled?

    send("#{notification_type}")
  end

  def subscription_update
    $wechat_client.send_template_msg(login_bind.uid, ENV['NOTIFICATION_WECHAT_REPORT_GENERATE_TEMPLATE_ID'], subject_url, '', {
      keyword1: { value: "#{subject_name} 报告更新" },
      keyword2: { value: params[:subject].status_updated_at.in_time_zone("Beijing").strftime("%Y-%m-%d %H:%M:%S") },
    })
  end

  def submission
    $wechat_client.send_template_msg(login_bind.uid, ENV['NOTIFICATION_WECHAT_REPORT_GENERATE_TEMPLATE_ID'], subscription_url, '', {
      keyword1: { value: "#{subject_name} 报告提交" },
      keyword2: { value: params[:subject].status_updated_at.in_time_zone("Beijing").strftime("%Y-%m-%d %H:%M:%S") },
    })
  end

  def subscription_create
    $wechat_client.send_template_msg(login_bind.uid, ENV['NOTIFICATION_WECHAT_REPORT_SUBSCRIPTION_UPDATE_TEMPLATE_ID'], subject_url, '', {
      keyword1: { value: '项目订阅' },
      keyword2: { value: "新增 #{subject_name} 报告更新订阅" },
    })
  end

  def subscription_delete
    $wechat_client.send_template_msg(login_bind.uid, ENV['NOTIFICATION_WECHAT_REPORT_SUBSCRIPTION_UPDATE_TEMPLATE_ID'], subscription_url, '', {
      keyword1: { value: '项目订阅' },
      keyword2: { value: "取消 #{subject_name} 报告更新订阅" },
    })
  end

  def enabled?
    @login_bind = user.login_binds.find_by(provider: 'wechat')
    @login_bind.present?
  end
end
