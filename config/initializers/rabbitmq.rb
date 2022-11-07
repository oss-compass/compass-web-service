class RabbitMQ
  # You can create the exchange and queue on top of the mq web beforehand, and create a binding and routing relationship
  class << self
    # here env['MQ_CONNECTION'], configured in the environment variable, e.g.: amqp://username:password@rabbitmq_server_ip
    def connection
      @connection ||= Bunny.new(ENV.fetch('MQ_CONNECTION')).start
    end

    def channel
      @channel = connection.create_channel
    end

    # for example： exchange = RabbitMQ.exchange("exchange_name", {durable: true_or_false, queue: :queue_name})
    def queue(name, options = {})
      channel.queue(name, options.merge(durable: true))
    end

    def publish(queue_name, message = {})
      queue(queue_name).publish(message.to_json, content_type: "application/json")
      @channel.close
    end
  end
end
