require 'addressable/uri'

class AnalyzeServer

  ANALYZE_QUEUE = 'analyze_queue'
  TASK = 'micro_server.analyze'
  SUPPORT_DOMAINS = ['gitee.com', 'github.com', 'gitlab.com']

  class TaskExists < StandardError; end
  class ValidateError < StandardError; end

  def initialize(opts = {})
    opts = opts.to_h.with_indifferent_access
    @raw = !!opts[:raw]
    @enrich = !!opts[:enrich]
    @identities_load = !!opts[:identities_load]
    @identities_merge = !!opts[:identities_merge]
    @panels = !!opts[:panels]
    @metrics = !!opts[:metrics]
    @debug = !!opts[:debug]
    @project_url = opts[:project_url]
    if @project_url.present?
      uri = Addressable::URI.parse(@project_url)
      @project_url = "#{uri&.scheme}://#{uri&.normalized_host}#{uri&.path}"
      @domain = uri&.normalized_host
    end
  end

  def initialize_analyze_status
    Rails.cache.write(analyze_status_key, { status: 'pending', message: '' })
  end

  def update_analyze_status(status = {})
    Rails.cache.write(analyze_status_key, status)
  end

  def get_analyze_status
    Rails.cache.read(analyze_status_key)
  end

  def perform_async
    validate!
    RabbitMQ.publish(
      ANALYZE_QUEUE,
      {
        task: TASK,
        args: [{
                 raw: @raw,
                 enrich: @enrich,
                 identities_load: @identities_load,
                 identities_merge: @identities_merge,
                 panels: @panels,
                 metrics: @metrics,
                 debug: @debug,
                 project_url: @project_url,
               }]
      })

    initialize_analyze_status
    { result: :ok, message: 'Task is pending' }
  rescue TaskExists => ex
    { result: :none, message: ex.message }
  rescue ValidateError => ex
    { result: :error, message: ex.message }
  end

  private

  def analyze_status_key
    "analyze-#{@project_url}"
  end

  def validate!
    raise ValidateError.new('`project_url` is required') unless @project_url.present?

    unless SUPPORT_DOMAINS.include?(@domain)
      raise ValidateError.new("No support data source from: #{@project_url}")
    end

    tasks = [@raw, @enrich, @identities_load, @identities_merge, @panels, @metrics]
    raise ValidateError.new('No tasks enabled') unless tasks.any?

    result = Rails.cache.read(analyze_status_key)

    result = result.to_h.with_indifferent_access
    puts result

    if result&.[](:status) == 'pending'
      raise TaskExists.new('Task already exists!')
    end

    if result&.[](:status) == 'analyzing'
      raise TaskExists.new('Task is analyzing!')
    end
  end
end
