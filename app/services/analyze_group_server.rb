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
    @domain_persona = opts[:domain_persona] || true
    @milestone_persona = opts[:milestone_persona] || true
    @role_persona = opts[:role_persona] || true
    @callback = opts[:callback]
    @level = 'community'
    @software_repos, @governance_repos = [], []

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

  def extract_repos
    Rails.logger.info("Extracting repos from #{@yaml_url}")

    repos = { 'software-artifact' => [], 'governance' => [] }
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
          next unless uri.scheme.present? && uri.normalized_host.present? && uri.path.present?
          repos[suffix] << "https://#{uri&.normalized_host}#{uri.path}"
        end
      end
    end
    [repos['software-artifact'] || [], repos['governance'] || []]
  rescue => ex
    Rails.logger.error("Failed to extract repos, error: #{ex.message}")
    [[], []]
  end

  def repos_count
    (@software_repos + @governance_repos).uniq.length
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

    @software_repos, @governance_repos = extract_repos

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
        metrics_domain_persona: @domain_persona,
        metrics_milestone_persona: @milestone_persona,
        metrics_role_persona: @role_persona,
        panels: false,
        project_template_yaml: @yaml_url,
        raw: @raw,
        level: @level,
        callback: @callback
      }
    }
  end

  def submit_task_status
    repo_task = ProjectTask.find_by(remote_url: @yaml_url) || ProjectTask.find_by(project_name: @project_name)

    response =
      Faraday.post(
        "#{CELERY_SERVER}/api/workflows",
        payload.to_json,
        { 'Content-Type' => 'application/json' }
      )
    task_resp = JSON.parse(response.body)
    extra = {}

    if repo_task.present?
      repo_task.update(status: task_resp['status'], task_id: task_resp['id'])
      if repo_task.extra.present?
        extra = JSON.parse(repo_task.extra) rescue {}
      end
      if @raw_yaml['community_org_url'] && extra['community_org_url'] != @raw_yaml['community_org_url']
        extra['community_org_url'] = @raw_yaml['community_org_url']
      end
      if @raw_yaml['community_logo_url'] && extra['community_logo_url'] != @raw_yaml['community_logo_url']
        extra['community_logo_url'] = @raw_yaml['community_logo_url']
      end
      repo_task.update(extra: extra.to_json)
    else
      extra['community_org_url'] = @raw_yaml['community_org_url'] if @raw_yaml['community_org_url']
      extra['community_logo_url'] = @raw_yaml['community_logo_url'] if @raw_yaml['community_logo_url']
      ProjectTask.create(
        task_id: task_resp['id'],
        remote_url: @yaml_url,
        status: task_resp['status'],
        payload: payload.to_json,
        level: @level,
        extra: (extra.to_json if extra.present? rescue nil),
        project_name: @project_name
      )
    end

    count = repos_count
    sync_subject_refs

    message = { label: @project_name, level: @level, status: Subject.task_status_converter(task_resp['status']), count: count, status_updated_at: DateTime.now.utc.iso8601 }

    RabbitMQ.publish(SUBSCRIPTION_QUEUE, message) if count > 0
    { status: task_resp['status'], message: I18n.t('analysis.task.pending') }
  rescue => ex
    Rails.logger.error("Failed to sumbit task #{@yaml_url} status, #{ex.message}")
    { status: ProjectTask::UnSubmit, message: I18n.t('analysis.task.unsubmit') }
  end

  def sync_subject_refs
    subject = Subject.find_by(label: @project_name, level: 'community')
    Subject.sync_subject_repos_refs(subject, new_software_repos: @software_repos, new_governance_repos: @governance_repos) if subject
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
