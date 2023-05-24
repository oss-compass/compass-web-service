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

    subject = Subject.find_or_create_by(label: label) do |subject|
      subject.level = level
      subject.status = status
      subject.count = count
      subject.status_updated_at = status_updated_at
    end

    notification_type =  message['status'] == ProjectTask::Pending ? NotificationService::SUBMISSION : NotificationService::SUBSCRIPTION_UPDATE

    subject.subscriptions.includes(:user).each do |subscription|
      NotificationService.new(subscription.user,notification_type, {subject: subject}).execute
    end

    ack!
  end
end
