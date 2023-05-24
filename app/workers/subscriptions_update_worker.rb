class SubscriptionsUpdateWorker
  include Sneakers::Worker
  from_queue 'subscriptions_update_v1',
             :ack => true,
             :timeout_job_after => 60,
             :retry_max_times => 3

  def work(msg)
    message = JSON.parse(msg)
    puts "Receiving a deserialization message is:"
    puts message

    status = Subject::task_status_converter(message['status'])
    label = message['label']
    level = message['level']
    count = message['count']
    status_updated_at = message['status_updated_at']

    subject = Subject.find_by(label: label)
    if subject.blank?
      subject = Subject.create!(
        label: label,
        level: level,
        status: status,
        status_updated_at: status_updated_at,
        count: count
      )
    end
    subject.status != status && subject.update!(status: status)

    notification_flag = true
    case status
    when Subject::COMPLETE
      notification_type = NotificationService::SUBSCRIPTION_UPDATE
    when message['status'] == ProjectTask::Pending
      notification_type = NotificationService::SUBMISSION
    else
      notification_flag = false
    end

    if notification_flag
      subject.subscriptions.includes(:user).each do |subscription|
        NotificationService.new(subscription.user, notification_type, { subject: subject }).execute
      end
    end

    ack!
  end
end
