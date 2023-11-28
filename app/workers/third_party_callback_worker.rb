class ThirdPartyCallbackWorker
  include Sneakers::Worker

  Enable = ENV.fetch('THIRD_PARTY_CALLBACK_ENABLE') { false }
  Token = ENV.fetch('THIRD_PARTY_CALLBACK_TOKEN') { '' }
  CallbackUrl = ENV.fetch('THIRD_PARTY_CALLBACK_URL') { '' }
  LimitOrigins = ENV.fetch('THIRD_PARTY_CALLBACK_ORIGINS') { 'gitee' }

  from_queue 'third_party_callback_v1',
             :ack => true,
             :timeout_job_after => 60,
             :retry_max_times => 3

  def work(msg)
    message = JSON.parse(msg)
    Sneakers.logger.info "Receiving a deserialization message is: #{message} for callback"

    status = message['status']
    label = message['label']
    level = message['level']
    origin = message['origin']
    status_updated_at = message['status_updated_at']
    repo_type = level == 'community' ? 'software-artifact' : nil
    if Enable && status == Subject::COMPLETE && LimitOrigins.include?(origin)
      body = MetricModelsServer.new(label: label, level: level, repo_type: repo_type).overview
      resp = Faraday.post(CallbackUrl, body.to_json, { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{Token}"})
      Sneakers.logger.info "Receiving a callback response is: #{resp.body}"
    end
    ack!
  end
end
