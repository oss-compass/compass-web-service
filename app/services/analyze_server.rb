# frozen_string_literal: true

class AnalyzeServer
  PROJECT = 'insight'
  WORKFLOW = 'ETL_V1'

  include Common
  include CompassUtils

  class TaskExists < StandardError; end

  class ValidateError < StandardError; end

  class ValidateFailed < StandardError; end

  def initialize(opts = {})
    @raw = opts.fetch(:raw, true)
    @enrich = opts.fetch(:enrich, true)
    @identities_load = opts.fetch(:identities_load, true)
    @identities_merge = opts.fetch(:identities_merge, true)
    @repo_url = opts[:repo_url]
    @activity = opts.fetch(:activity, true)
    @community = opts.fetch(:community, true)
    @codequality = opts.fetch(:codequality, true)
    @group_activity = opts.fetch(:group_activity, true)
    @domain_persona = opts.fetch(:domain_persona, true)
    @milestone_persona = opts.fetch(:milestone_persona, true)
    @role_persona = opts.fetch(:role_persona, true)
    @callback = opts[:callback]
    @developers = opts[:developers] || {}

    if @repo_url.present?
      uri = Addressable::URI.parse(@repo_url)
      @repo_url = "https://#{uri&.normalized_host}#{uri&.path}"
      @domain = uri&.normalized_host
      @domain_name = @domain.starts_with?('gitee.com') ? 'gitee' : 'github'
      @project_name = @repo_url
    end
  end

  def repo_task
    @repo_task ||= ProjectTask.find_by(remote_url: @repo_url)
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

      result = update_developers
      return result unless result[:status]

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

  private

  def validate!
    raise ValidateFailed.new(I18n.t('analysis.validation.missing', field: 'repo_url')) unless @repo_url.present?

    unless SUPPORT_DOMAINS.include?(@domain)
      raise ValidateFailed.new(I18n.t('analysis.validation.not_support', source: @repo_url))
    end

    tasks = [@raw, @enrich, @activity, @community, @codequality, @group_activity]
    raise ValidateFailed.new(I18n.t('analysis.validation.no_tasks')) unless tasks.any?

    validate_project!
  end

  def validate_project!
    url = "#{@repo_url}.git/info/refs?service=git-upload-pack"
    ret_code =
      if @domain&.starts_with?('gitee.com')
        Faraday.get(url).status
      else
        RestClient::Request.new(method: :get, url: url, proxy: PROXY).execute.code
      end
    raise ValidateFailed.new(I18n.t('analysis.validation.cannot_access')) unless ret_code == 200
  rescue => ex
    Rails.logger.error("This repository `#{@repo_url}` can not access, error: #{ex.message}")
    raise ValidateError.new(I18n.t('analysis.validation.cannot_access_with_tip'))
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
        project_url: @repo_url,
        raw: @raw,
        callback: @callback
      }
    }
  end

  def submit_task_status
    repo_task = ProjectTask.find_by(remote_url: @repo_url)

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
        remote_url: @repo_url,
        status: task_resp['status'],
        payload: payload.to_json,
        level: 'repo',
        project_name: @project_name
      )
    end

    message = { label: @repo_url, level: 'repo', status: Subject.task_status_converter(task_resp['status']), count: 1, status_updated_at: DateTime.now.utc.iso8601 }
    RabbitMQ.publish(SUBSCRIPTION_QUEUE, message)
    { status: task_resp['status'], message: I18n.t('analysis.task.pending') }
  rescue => ex
    Rails.logger.error("Failed to sumbit task #{@repo_url} status, #{ex.message}")
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

  def update_developers
    return { status: true, message: 'skipped' } unless @developers.present? && @callback&.dig(:params, :pr_number).present?
    pr_number = @callback&.dig(:params, :pr_number)
    @developers.each do |contributor, org_lines|
      organizations = org_lines.map do |org_line|
        pattern = /(?<org_name>[a-zA-Z0-9_-]+) from (?<first_date>\d{4}-\d{2}-\d{2}) until (?<last_date>\d{4}-\d{2}-\d{2})/
        match_data = org_line.match(pattern)
        OpenStruct.new(
          org_name: match_data[:org_name],
          first_date: Date.parse(match_data[:first_date]),
          last_date: Date.parse(match_data[:last_date])
        )
      end
      Input::ContributorOrgInput.validate_no_overlap(organizations)
      uuid = get_uuid(contributor, ContributorOrg::RepoAdmin, @repo_url, 'repo', @domain_name)
      record = OpenStruct.new(
        {
          id: uuid,
          uuid: uuid,
          contributor: contributor,
          org_change_date_list: organizations.map(&:to_h),
          modify_by: pr_number,
          modify_type: ContributorOrg::RepoAdmin,
          platform_type: @domain_name,
          is_bot: false,
          label: @repo_url,
          level: 'repo',
          update_at_date: Time.current
        }
      )
      ContributorOrg.import(record)
    end
    { status: true, message: '' }
  rescue => ex
    Rails.logger.error("Failed to update developers #{repo_task.task_id} status, #{ex.message}")
    { status: false, message: ex.message }
  end
end
