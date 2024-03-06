class RabbitMQ
  # You can create the exchange and queue on top of the mq web beforehand, and create a binding and routing relationship
  class << self
    # here env['MQ_CONNECTION'], configured in the environment variable, e.g.: amqp://username:password@rabbitmq_server_ip
    def publish(queue_name, message = {})
      publisher = Sneakers::Publisher.new
      publisher.publish(message.to_json, to_queue: queue_name, mandatory: true)
      publisher.instance_variable_get(:@bunny).close
    end
  end
end
