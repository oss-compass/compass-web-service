require 'sneakers/handlers/maxretry'

opts = {
  handler: Sneakers::Handlers::Maxretry,
  amqp: ENV.fetch('MQ_CONNECTION'),
  log: "log/sneakers.log",
  pid_path: "tmp/pids/sneakers.pid",
  threads: 32,
  workers: 4,
}

Sneakers.configure(opts)
Sneakers.logger.formatter = ::Logger::Formatter.new
Sneakers.logger.level = Logger::INFO
