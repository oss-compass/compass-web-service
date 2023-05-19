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
    ack!
  end
end
