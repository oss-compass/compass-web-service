class AnalyzeResWorker
  include Sneakers::Worker
  # worker从analyze_result队列里面取数据
  from_queue "analyze_result"

  def work(msg)
    logger.info "AnalyzeResWorker::work msg #{msg}"
    data = JSON.parse(msg)
    case data
        in [args, _kwargs, _headers]
        AnalyzeServer.new(args[0]).update_analyze_status(args[0])
    else
      logger.info "AnalyzeResWorker::work unknown msg #{msg}"
    end
    # 给队列发送确认信息
    ack!
  rescue => ex
    logger.error("AnalyzeResWorker Error: #{ex.message}")
  end
end
