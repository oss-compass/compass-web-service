# frozen_string_literal: true

class AnalyzeGroupServer
  PROJECT = 'insight'
  WORKFLOW = 'ETL_V1_GROUP'

  include Common

  class TaskExists < StandardError; end

  class ValidateError < StandardError; end

  class ValidateFailed < StandardError; end

  def initialize(opts = {})
    @yaml_url = opts[:yaml_url]
    @raw_yaml = opts[:raw_yaml]
    @raw = opts[:raw] || true
    @enrich = opts[:enrich] || true
    @identities_load = opts[:identities_load] || true
    @identities_merge = opts[:identities_merge] || true
    @activity = opts[:activity] || true
    @community = opts[:community] || true
    @codequality = opts[:codequality] || true
    @group_activity = opts[:group_activity] || true
    @callback = opts[:callback]
    @level = 'community'

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
      raise TaskExists.new(I18n.t('analysis.task.submitted'))
    end

    if only_validate
      { status: true, message: I18n.t('analysis.validation.pass') }
    else
      result = submit_task_status
      { status: result[:status], message: result[:message] }
    end
  rescue TaskExists => ex
    { status: :progress, message: ex.message }
  rescue ValidateFailed => ex
    { status: :error, message: ex.message }
  rescue ValidateError => ex
    { status: nil, message: ex.message }
  end

  def repos_count
    count = 0
    begin
      @raw_yaml['resource_types'].each do |project_type, project_info|
        suffix = nil
        if %w[software-artifact-repositories software-artifact-resources software-artifact-projects].include?(project_type)
          suffix = 'software-artifact'
        end
        if %w[governance-repositories governance-resources governance-projects].include?(project_type)
          suffix = 'governance'
        end
        if suffix
          urls = project_info['repo_urls']
          urls.each do |project_url|
            uri = Addressable::URI.parse(project_url)
            next unless uri.scheme.present? && uri.host.present?
            count += 1
          end
        end
      end
      count
    rescue
      count
    end
  end

  private

  def validate!
    raise ValidateFailed.new('`yaml_url` is required') unless @yaml_url.present? || @raw_yaml.present?

    if @yaml_url.present? && !SUPPORT_DOMAINS.include?(@domain)
      raise ValidateFailed.new("No support data source from: #{@yaml_url}")
    end

    tasks = [@raw, @enrich, @activity, @community, @codequality, @group_activity]
    raise ValidateFailed.new('No tasks enabled') unless tasks.any?

    if @raw_yaml.present?
      @raw_yaml = YAML.load(@raw_yaml)
    else
      req = { method: :get, url: @yaml_url }
      req.merge!(proxy: PROXY) unless @domain.start_with?('gitee')
      @raw_yaml = YAML.load(RestClient::Request.new(req).execute.body)
    end

    @project_name = @raw_yaml['community_name']
    raise ValidateFailed.new('Invalid community name') unless @project_name.present?

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
        identities_load: @identities_load,
        identities_merge: @identities_merge,
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
      if repo_task.extra.present?
        extra = JSON.parse(repo_task.extra) rescue {}
        if @raw_yaml['community_url'] && extra['community_url'] != @raw_yaml['community_url']
          repo_task.update(extra: extra.merge({community_url: @raw_yaml['community_url']}).to_json)
        end
      end
    else
      ProjectTask.create(
        task_id: task_resp['id'],
        remote_url: @yaml_url,
        status: task_resp['status'],
        payload: payload.to_json,
        level: @level,
        extra: ({community_url: @raw_yaml['community_url']}.to_json if @raw_yaml['community_url'] rescue nil),
        project_name: @project_name
      )
    end
    count = repos_count

    message = { label: @project_name, level: @level, status: Subject.task_status_converter(task_resp['status']), count: count, status_updated_at: DateTime.now.iso8601 }

    RabbitMQ.publish(SUBSCRIPTION_QUEUE, message) if count > 0
    { status: task_resp['status'], message: I18n.t('analysis.task.pending') }
  rescue => ex
    Rails.logger.error("Failed to sumbit task #{@yaml_url} status, #{ex.message}")
    { status: ProjectTask::UnSubmit, message: I18n.t('analysis.task.unsubmit') }
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
