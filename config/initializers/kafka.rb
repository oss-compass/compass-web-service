require 'waterdrop'
require 'connection_pool'


KAFKA_PRODUCERS_CP = ConnectionPool.new do
  WaterDrop::Producer.new do |config|
    config.deliver = true
    mechanism = ENV.fetch('KAFKA_MECHANISM') { nil }
    if mechanism
      config.kafka = {
        'bootstrap.servers': ENV.fetch('KAFKA_SERVERS') { '127.0.0.1:9092' },
        'request.required.acks': ENV.fetch('KAFKA_ACKS') { 1 },
        'sasl.username': ENV.fetch('KAFKA_USERNAME') { 'username' },
        'sasl.password': ENV.fetch('KAFKA_PASSWORD') { 'password' },
        'sasl.mechanism': ENV.fetch('KAFKA_MECHANISM') { 'SCRAM-SHA-256' }
        'security.protocol': ENV.fetch('KAFKA_PROTOCOL') { 'SASL_PLAINTEXT' }
      }
    else
      config.kafka = {
        'bootstrap.servers': ENV.fetch('KAFKA_SERVERS') { '127.0.0.1:9092' },
        'request.required.acks': ENV.fetch('KAFKA_ACKS') { 1 },
      }
    end
    config.monitor = WaterDrop::Instrumentation::Monitor.new
  end
end

class CompassKafka
  def self.pool
    KAFKA_PRODUCERS_CP
  end
end

at_exit { KAFKA_PRODUCERS_CP.shutdown { |producer| producer.close } }
