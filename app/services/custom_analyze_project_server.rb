# frozen_string_literal: true

class CustomAnalyzeProjectServer
  PROJECT = 'insight'
  WORKFLOW = 'CUSTOM_V1'
  LongCacheTTL = 3.days
  CacheTTL = 2.minutes

  include Common

  attr_reader :user, :model, :version, :project

  class TaskExists < StandardError; end

  class ValidateError < StandardError; end

  class ValidateFailed < StandardError; end

  def initialize(opts = { user:, model:, version:, project: })
    @user = opts[:user]
    @model = opts[:model]
    @version = opts[:version]
    @project = opts[:project]
  end

  def project_urls
    [project]
  end

  def algorithm
    version.algorithm.extra
  end

  def custom_fields
    { model_id: model.id, version_id: version.id }
  end

  def metrics_weights_thresholds
    version.metrics.reduce({}) do |acc, metric|
      acc.merge(
        {
          metric.ident => {
            threshold: metric.threshold,
            weight: metric.weight
          }
        }
      )
    end
  end

  def analysis_task_key
    "#{self.class.name}:#{model.id}:#{version.id}:#{project}:task_status"
  end

  def analysis_response_key
    "#{self.class.name}:#{model.id}:#{version.id}:#{project}:task_response"
  end

  def task_info
    Rails.cache.fetch(analysis_task_key, expires_in: LongCacheTTL) do
      {
        'trigger_user_id' => user&.id,
        'task_id' => nil,
        'status' => ProjectTask::UnSubmit,
        'updated_at' => nil
      }
    end
  end

  def update_task_info(task_id:, status:, updated_at:)
    task_info = { 'trigger_user_id' => user&.id }
    task_info['task_id'] = task_id if task_id.present?
    task_info['status'] = status if status.present?
    task_info['updated_at'] = updated_at if updated_at.present?
    Rails.cache.write(analysis_task_key, task_info, expires_in: LongCacheTTL)
  end

  def check_task_status
    task_id = task_info&.[]('task_id')
    if task_id.present?
      update_task_status(task_id)
    end
    status = task_info&.[]('status')
    return status if status != ProjectTask::UnSubmit
    return ProjectTask::Success if CustomV1Metric.exist_model_and_version(model.id, version.id)
    status
  end

  def check_task_updated_time
    task_id = task_info&.[]('task_id')
    if task_id.present?
      update_task_status(task_id)
    end
    DateTime.parse(task_info&.[]('updated_at'))
  rescue
    nil
  end

  def execute
    validate!

    status = check_task_status

    if ProjectTask::Processing.include?(status)
      raise TaskExists.new(I18n.t('analysis.task.submitted'))
    end

    result = submit_task_status

    { status: result[:status], message: result[:message] }
  rescue TaskExists => ex
    { status: :progress, message: ex.message }
  rescue ValidateFailed => ex
    { status: :error, message: ex.message }
  end

  private

  def validate!
    project_urls.each do |url|
      uri = Addressable::URI.parse(url)
      domain = uri&.normalized_host
      unless SUPPORT_DOMAINS.include?(domain)
        raise ValidateFailed.new(I18n.t('analysis.validation.not_support', source: url))
      end
    end
  end

  def payload
    {
      project: PROJECT,
      name: WORKFLOW,
      payload: {
        deubg: false,
        level: 'repo',
        custom_fields: custom_fields,
        project_urls: project_urls,
        metrics_weights_thresholds: metrics_weights_thresholds
      }
    }
  end

  def submit_task_status
    response =
      Faraday.post(
        "#{CELERY_SERVER}/api/workflows",
        payload.to_json,
        { 'Content-Type' => 'application/json' }
      )
    task_resp = JSON.parse(response.body)

    update_task_info(status: task_resp['status'], task_id: task_resp['id'], updated_at: task_resp['updated'])

    model.decreasing_trigger_remaining_count

    { status: task_resp['status'], message: I18n.t('analysis.task.pending') }
  rescue => ex
    Rails.logger.error("Failed to sumbit task Model #{model.id}: Version #{version.id}: ReportId #{report.id}  status, #{ex.message}")
    { status: ProjectTask::UnSubmit, message: I18n.t('analysis.task.unsubmit') }
  end

  def update_task_status(task_id)
    response = Faraday.get("#{CELERY_SERVER}/api/workflows/#{task_id}")
    task_resp = JSON.parse(response.body)
    update_task_info(status: task_resp['status'], task_id: task_id, updated_at: task_resp['updated'])
  rescue => ex
    Rails.logger.error("Failed to update task #{task_id} status, #{ex.message}")
  end
end
