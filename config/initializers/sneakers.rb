require 'sneakers/handlers/maxretry'

opts = {
  handler: Sneakers::Handlers::Maxretry,
  amqp: ENV.fetch('MQ_CONNECTION'),
  log: "log/sneakers.log",
  pid_path: "tmp/pids/sneakers.pid",
  threads: 64,
  workers: 8,
  hooks: {
    before_fork: lambda do
      ::ActiveRecord::Base.clear_all_connections!
    end,
    after_fork: lambda do
      ::ActiveRecord::Base.establish_connection
    end
  }
}

Sneakers.configure(opts)
Sneakers.logger.formatter = ::Logger::Formatter.new
Sneakers.logger.level = Logger::INFO
