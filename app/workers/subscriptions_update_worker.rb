class SubscriptionsUpdateWorker
  include Sneakers::Worker
  from_queue 'subscriptions_update_v1',
             :ack => true,
             :timeout_job_after => 60,
             :retry_max_times => 3

  def work(msg)
    message = JSON.parse(msg)
    Sneakers.logger.info "Receiving a deserialization message is: #{message}"

    status = message['status']
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
    if subject.status != status
      update_attributes = { status: status, status_updated_at: status_updated_at }
      if status == Subject::PROGRESS
        update_attributes.merge!({ collect_at: status_updated_at })
      elsif status == Subject::COMPLETE
        update_attributes.merge!({ complete_at: status_updated_at })
      end
      subject.update!(update_attributes)
    end

    if subject.status == Subject::COMPLETE
      subject.subscriptions.includes(:user).each do |subscription|
        NotificationService.new(subscription.user, NotificationService::SUBSCRIPTION_UPDATE, { subject: subject }).execute
      end
    end

    ack!
  end
end
