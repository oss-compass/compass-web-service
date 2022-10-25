# frozen_string_literal: true

class AnalyzeGroupServer
  PROJECT = 'insight'
  WORKFLOW = 'ETL_V1_GROUP'

  include Common

  class TaskExists < StandardError; end
  class ValidateError < StandardError; end

  def initialize(opts = {})
    @yaml_url = opts[:yaml_url]
    @raw_yaml = opts[:raw_yaml]
    @raw = opts[:raw] || true
    @enrich = opts[:enrich] || true
    @activity = opts[:activity] || true
    @community = opts[:community] || true
    @codequality = opts[:codequality] || true
    @group_activity = opts[:group_activity] || true
    @callback = opts[:callback]
    @level = 'project'

    if @yaml_url.present?
      uri = Addressable::URI.parse(@yaml_url)
      @yaml_url = "https://#{uri&.normalized_host}#{uri&.path}"
      @domain = uri&.normalized_host
    end
  end

  def repo_task
    @repo_task ||= ProjectTask.find_by(remote_url: @yaml_url)
  end

  def check_task_status
    if repo_task.present?
      update_task_status
      repo_task.status
    else
      ProjectTask::UnSubmit
    end
  end

  def execute(only_validate: false)
    validate!

    status = check_task_status

    if ProjectTask::Processing.include?(status)
      raise TaskExists.new('Task already sumbitted!')
    end

    if only_validate
      { status: true, message: 'Validation passed' }
    else
      result = submit_task_status
      { status: result[:status], message: result[:message] }
    end
  rescue TaskExists => ex
    { status: :progress, message: ex.message }
  rescue ValidateError => ex
    { status: :error, message: ex.message }
  end

  private

  def validate!
    raise ValidateError.new('`yaml_url` is required') unless @yaml_url.present? || @raw_yaml.present?

    if @yaml_url.present? && !SUPPORT_DOMAINS.include?(@domain)
      raise ValidateError.new("No support data source from: #{@yaml_url}")
    end

    tasks = [@raw, @enrich, @activity, @community, @codequality, @group_activity]
    raise ValidateError.new('No tasks enabled') unless tasks.any?

    if @raw_yaml.present?
      @raw_yaml = YAML.load(@raw_yaml)
    else
      req = { method: :get, url: @yaml_url }
      req.merge!(proxy: PROXY) unless @domain.start_with?('gitee')
      @raw_yaml = YAML.load(RestClient::Request.new(req).execute.body)
    end

    @project_name = @raw_yaml['organization_name']
    raise ValidateError.new('Invalid organization name') unless @project_name.present?

  rescue => ex
    raise ValidateError.new(ex.message)
  end

  def payload
    {
      project: PROJECT,
      name: WORKFLOW,
      payload: {
        deubg: false,
        enrich: @enrich,
        identities_load: false,
        identities_merge: false,
        metrics_activity: @activity,
        metrics_codequality: @codequality,
        metrics_community: @community,
        metrics_group_activity: @group_activity,
        panels: false,
        project_template_yaml: @yaml_url,
        raw: @raw,
        level: @level,
        callback: @callback
      }
    }
  end

  def submit_task_status
    repo_task = ProjectTask.find_by(remote_url: @yaml_url)

    response =
      Faraday.post(
        "#{CELERY_SERVER}/api/workflows",
        payload.to_json,
        { 'Content-Type' => 'application/json' }
      )
    task_resp = JSON.parse(response.body)

    if repo_task.present?
      repo_task.update(status: task_resp['status'], task_id: task_resp['id'])
    else
      ProjectTask.create(
        task_id: task_resp['id'],
        remote_url: @yaml_url,
        status: task_resp['status'],
        payload: payload.to_json,
        level: @level,
        project_name: @project_name
      )
    end
    { status: task_resp['status'], message: 'Task is pending' }
  rescue => ex
    Rails.logger.error("Failed to sumbit task #{@yaml_url} status, #{ex.message}")
    { status: ProjectTask::UnSubmit, message: 'Failed to sumbit task, please retry' }
  end

  def update_task_status
    if repo_task.task_id
      response =
        Faraday.get("#{CELERY_SERVER}/api/workflows/#{repo_task.task_id}")
      task_resp = JSON.parse(response.body)
      repo_task.update(status: task_resp['status'])
    end
  rescue => ex
    Rails.logger.error("Failed to update task #{repo_task.task_id} status, #{ex.message}")
  end
end
