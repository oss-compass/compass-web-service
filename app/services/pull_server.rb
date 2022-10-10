# frozen_string_literal: true
class PullServer
  include GiteeApplication
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
    if @extra.is_a?(Hash) && SUPPORT_DOMAIN_NAMES.include?(@extra[:origin])
      @domain_name = @extra[:origin]
    end
  end

  def update_workflow
    result = validate
    return result unless result[:status]

    case @level
    when 'repo'
      path = "single-projects/#{@domain_name}#{@path}.yml"
      message = "Updated #{path}"
      branch = "#{DateTime.now.strftime('%Y%m%d%H%M%S')}#{@path.gsub('/', '-')}"
      repo = {}
      repo['data_sources'] = { 'repo_name' => @project_url }
      content_base64 = Base64.strict_encode64(YAML.dump(repo))
      pr_desc = "submitted by @#{@extra[:username]}"

      if @domain_name == 'gitee'

        result = gitee_create_branch(branch)
        return result unless result[:status]

        result = gitee_post_file(path, message, content_base64, branch)
        return result unless result[:status]

        result = gitee_create_pull(message, pr_desc, branch)
        return result unless result[:status]
        { status: true, pr_url: result[:pr_url] }
      else
        result = github_get_head_sha()
        return result unless result[:status]

        result = github_create_ref(branch, result[:sha])
        return result unless result[:status]

        result = github_put_file(path, message, content_base64, branch)
        return result unless result[:status]

        result = github_create_pull(message, pr_desc, branch)
        return result unless result[:status]
        { status: true, pr_url: result[:pr_url] }
      end
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

  def validate
    case @extra
         in { username: username, origin: origin, token: token }
         result =
           if origin == 'gitee'
             gitee_get_user_info(token)
           else
             github_get_user_info(token)
           end
         case result
             in { status: true, username: real_login }
             if username.downcase == real_login.downcase
               { status: true, message: 'user verification pass' }
             else
                { status: false, message: 'user verification failed' }
             end
         else
           { status: false, message: result[:message] }
         end
    else
      { status: false, message: 'invalid user information' }
    end
  end
end
