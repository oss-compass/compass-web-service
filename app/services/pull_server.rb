# frozen_string_literal: true
class PullServer
  include GithubApplication

  def initialize(opts = {})
    @label = opts[:label]
    @level = opts[:level]
    @project_url = opts[:project_url]
    @project_types = opts[:project_types]
    if @project_url.present?
      uri = Addressable::URI.parse(@project_url)
      @domain = uri&.normalized_host
      @domain_name = @domain.starts_with?('gitee.com') ? 'gitee' : 'github'
      @path = uri.path
    end
    @extra = opts[:extra]
  end

  def update_workflow
    case @level
    when 'repo'
      path = "single-projects/#{@domain_name}#{@path}.yml"
      message = "Updated #{path}"

      result = github_get_head_sha()
      return result unless result[:status]

      branch = "#{DateTime.now.strftime('%Y%m%d%H%M%S')}#{@path.gsub('/', '-')}"
      result = github_create_ref(branch, result[:sha])
      return result unless result[:status]

      repo = {}
      repo['data_sources'] = { 'repo_name' => @project_url }
      content_base64 = Base64.encode64(YAML.dump(repo))
      result = github_put_file(path, message, content_base64, branch)
      return result unless result[:status]

      result = github_create_pull(message, "submitted by @#{@extra[:username]}", branch)
      return result unless result[:status]

      { status: true, pr_url: result[:pr_url] }
    when 'project'
      path = "organizations/#{@label}.yml"
      message = "Updated #{path}"

      result = github_get_head_sha()
      return result unless result[:status]

      branch = "#{DateTime.now.strftime('%Y%m%d%H%M%S')}-#{@label.gsub('/', '-')}"
      result = github_create_ref(branch, result[:sha])
      return result unless result[:status]

      project = {}
      project['organization_name'] = @label
      project['project_types'] =
        @project_types.reduce({}) do |result, type|
        result.merge({ type.type => { 'data_sources' => { 'repo_names' => type.repo_list }}})
      end
      content_base64 = Base64.encode64(YAML.dump(project))
      result = github_put_file(path, message, content_base64, branch)
      return result unless result[:status]

      result = github_create_pull(message, "submitted by @#{@extra[:username]}", branch)
      return result unless result[:status]

      { status: true, pr_url: result[:pr_url] }
    else
      { status: false, message: 'invalid level' }
    end
  rescue => ex
    { status: false, message: ex.message }
  end

  def execute
    update_workflow
  end
end
