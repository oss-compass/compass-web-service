class SubmitTaskWorker < YamlCheckWorker
  include Sneakers::Worker
  include Common
  include GiteeApplication
  include GithubApplication

  from_queue 'submit_task_v1',
             :ack => true,
             :timeout_job_after => 60,
             :retry_max_times => 3

  def work(msg)
    execute(msg, false)
    ack!
  end
end
