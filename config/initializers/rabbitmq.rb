class RabbitMQ
  # You can create the exchange and queue on top of the mq web beforehand, and create a binding and routing relationship
  class << self
    # here env['MQ_CONNECTION'], configured in the environment variable, e.g.: amqp://username:password@rabbitmq_server_ip
    def publisher
       @publisher ||= Sneakers::Publisher.new
    end

    def publish(queue_name, message = {})
      publisher.publish(message.to_json, to_queue: queue_name)
    end
  end
end
