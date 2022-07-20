opts = {
  daemonize: true,
  amqp: ENV.fetch('MQ_CONNECTION'),
  log: "log/sneakers.log",
  pid_path: "tmp/pids/sneakers.pid",
  threads: 2,
  workers: 2,
}

Sneakers.configure(opts)
Sneakers.logger.level = Logger::INFO
