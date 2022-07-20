class RabbitMQ
  # 可以前提前在MQ Web上面创建好exchange和queue，并创建好绑定和路由的关系
  class << self
    #这里的ENV['mq_connection']，配置在环境变量里面，例如: amqp://user_name:password@rabbitmq_server_ip
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
