# frozen_string_literal: true
class PullServer
  include GiteeApplication
  include GithubApplication

  def initialize(opts = {})
    @label = opts[:label]
    @level = opts[:level]
    @project_url = opts[:project_url]
    @project_urls = opts[:project_urls]
    @project_types = opts[:project_types]
    @extra = opts[:extra]

    if @project_urls.present? && @project_urls.length == 1
      @project_url = @project_urls.first
    end

    if @project_url.present?
      uri = Addressable::URI.parse(@project_url)
      uri.path.sub!(/\.git$/, '')
      @domain = uri&.normalized_host
      @domain_name = @domain.starts_with?('gitee.com') ? 'gitee' : 'github'
      @path = uri.path
      @project_url = uri.to_s
    end

    if @extra.is_a?(Hash) && SUPPORT_DOMAIN_NAMES.include?(@extra[:origin])
      @domain_name = @extra[:origin]
    end
  end

  def update_workflow
    result = validate
    return result unless result[:status]

    case @level
    when 'repo'
      pr_desc = "submitted by @#{@extra[:username]}"
      if @project_url.present?
        path = "#{SINGLE_DIR}/#{@domain_name}#{@path}.yml"
        message = "Updated #{path}"
        branch = "#{DateTime.now.strftime('%Y%m%d%H%M%S')}#{@path.gsub('/', '-')}"
        repo = {}
        repo['resource_types'] = { 'repo_urls' => @project_url }
        content_base64 = Base64.strict_encode64(YAML.dump(repo))

        pr_desc = "#{pr_desc}, repository: #{@project_url}"

        if @domain_name == 'gitee'
          create_gitee_pull(branch, path, content_base64, message, pr_desc)
        else
          create_github_pull(branch, path, content_base64, message, pr_desc)
        end
      elsif @project_urls.present?

        if @project_urls.length > 5
          return { status: false, message: I18n.t('pull.too_many_repositories') }
        end

        branch = "#{DateTime.now.strftime('%Y%m%d%H%M%S')}-update-projects"
        message = "Updated projects"

        path_content_base64_pairs = {}
        @project_urls.each do |project_url|
          uri = Addressable::URI.parse(project_url)
          uri.path.sub!(/\.git$/, '')
          domain = uri&.normalized_host
          domain_name = domain.starts_with?('gitee.com') ? 'gitee' : 'github'
          path = "#{SINGLE_DIR}/#{domain_name}#{uri.path}.yml"
          repo = {}
          repo['resource_types'] = { 'repo_urls' => uri.to_s }
          content_base64 = Base64.strict_encode64(YAML.dump(repo))
          path_content_base64_pairs[path] = content_base64
        end

        pr_desc = "#{pr_desc}, repositories: #{@project_urls.join(',')}"

        if @domain_name == 'gitee'
          create_gitee_pull_with_multiple_files(branch, path_content_base64_pairs, message, pr_desc)
        else
          create_github_pull_with_multiple_files(branch, path_content_base64_pairs, message, pr_desc)
        end
      end

    when 'project', 'community'
      path = "#{ORG_DIR}/#{@label}.yml"
      message = "Updated #{path}"
      branch = "#{DateTime.now.strftime('%Y%m%d%H%M%S')}-#{@label.gsub('/', '-')}"
      project = {}
      project['community_name'] = @label
      project['resource_types'] =
        @project_types.reduce({}) do |result, type|
        result.merge({ type.type => { 'repo_urls' => type.repo_list } })
      end
      content_base64 = Base64.strict_encode64(YAML.dump(project))
      pr_desc = "submitted by @#{@extra[:username]}"

      if @domain_name == 'gitee'
        create_gitee_pull(branch, path, content_base64, message, pr_desc)
      else
        create_github_pull(branch, path, content_base64, message, pr_desc)
      end

    else
      { status: false, message: I18n.t('pull.invalid_level') }
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
               { status: true, message: I18n.t('pull.user.validation.pass') }
             else
                { status: false, message: I18n.t('pull.user.validation.failed') }
             end
         else
           { status: false, message: result[:message] }
         end
    else
      { status: false, message: I18n.t('pull.user.invalid') }
    end
  end

  private

  def create_gitee_pull(branch, path, content_base64, message, pr_desc)
    result = gitee_create_branch(branch)
    return result unless result[:status]

    result = gitee_post_file(path, message, content_base64, branch)
    return result unless result[:status]

    result = gitee_create_pull(message, pr_desc, branch)
    return result unless result[:status]
    { status: true, pr_url: result[:pr_url] }
  end

  def create_gitee_pull_with_multiple_files(branch, path_content_base64_pairs, message, pr_desc)
    result = gitee_create_branch(branch)
    return result unless result[:status]

    path_content_base64_pairs.each do |path, content_base64|
      result = gitee_post_file(path, message, content_base64, branch)
      return result unless result[:status]
    end

    result = gitee_create_pull(message, pr_desc, branch)
    return result unless result[:status]
    { status: true, pr_url: result[:pr_url] }
  end

  def create_github_pull(branch, path, content_base64, message, pr_desc)
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

  def create_github_pull_with_multiple_files(branch, path_content_base64_pairs, message, pr_desc)
    result = github_get_head_sha()
    return result unless result[:status]

    result = github_create_ref(branch, result[:sha])
    return result unless result[:status]

    path_content_base64_pairs.each do |path, content_base64|
      result = github_put_file(path, message, content_base64, branch)
      return result unless result[:status]
    end

    result = github_create_pull(message, pr_desc, branch)
    return result unless result[:status]
    { status: true, pr_url: result[:pr_url] }
  end
end
