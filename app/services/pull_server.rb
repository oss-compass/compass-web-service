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

    if @label.present? && @level.present?
      @subject = Subject.find_by(label: @label, level: @level)
      @project_url = @label if @level == 'repo'
    end

    if @project_url.present?
      uri = Addressable::URI.parse(@project_url)
      uri.path = uri.path.sub(/\.git$/, '')
      @domain = uri&.normalized_host
      @domain_name = @domain.starts_with?('gitee.com') ? 'gitee' : 'github'
      @path = uri.path
      @project_url = uri.to_s
    end

    if @extra.is_a?(Hash) && SUPPORT_DOMAIN_NAMES.include?(@extra[:origin])
      @domain_name = @extra[:origin]
    end
  end

  def update_developers
    result = subject_validate
    return result unless result[:status]

    pr_desc = "submitted by @#{@extra[:username]}"
    case @level
    when 'repo'
      path = "#{SINGLE_DIR}/#{@domain_name}#{@path}.yml"
      message = "Updated #{path} developers"
      branch = "#{DateTime.now.strftime('%Y%m%d%H%M%S')}#{@path.gsub('/', '-')}"
      result = @domain_name == 'gitee' ? gitee_get_file(path, 'main') : github_get_file(path, 'main')
      repo, sha = {}, nil
      sha = cacualte_sha(result[:body]) if result[:status]
      repo = YAML.load(result[:body]) rescue {} if result[:status]
      repo['resource_types'] = { 'repo_urls' => @project_url } if repo.blank?
      repo['developers'] ||= {}
      repo['developers'][@extra[:contributor]] = []
      @extra[:organizations]&.each do |o|
        repo['developers'][@extra[:contributor]] << "#{o.org_name} from #{o.first_date} until #{o.last_date}"
      end
      content_base64 = Base64.strict_encode64(YAML.dump(repo))

      if @domain_name == 'gitee'
        result = gitee_is_fork_repo(@project_url)
        return result unless result[:status]

        create_gitee_pull(branch, path, content_base64, message, pr_desc, sha: sha)
      else
        result = github_is_fork_repo(@project_url)
        return result unless result[:status]

        create_github_pull(branch, path, content_base64, message, pr_desc, sha: sha)
      end
    when 'project', 'community'
      path = "#{ORG_DIR}/#{@label}.yml"
      message = "Updated #{path}"
      branch = "#{DateTime.now.strftime('%Y%m%d%H%M%S')}-#{@label.gsub('/', '-')}"
      result = @domain_name == 'gitee' ? gitee_get_file(path, 'main') : github_get_file(path, 'main')
      return result unless result[:status]
      project = YAML.load(result[:body])
      sha = cacualte_sha(result[:body])
      project['developers'] ||= {}
      project['developers'][@extra[:contributor]] = []
      @extra[:organizations]&.each do |o|
        project['developers'][@extra[:contributor]] << "#{o.org_name} from #{o.first_date} until #{o.last_date}"
      end
      content_base64 = Base64.strict_encode64(YAML.dump(project))

      if @domain_name == 'gitee'
        create_gitee_pull(branch, path, content_base64, message, pr_desc, sha: sha)
      else
        create_github_pull(branch, path, content_base64, message, pr_desc, sha: sha)
      end

    else
      { status: false, message: I18n.t('pull.invalid_level') }
    end
  rescue => ex
    { status: false, message: ex.message }
  end

  def update_workflow
    result = duplicate_validate
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
          result = gitee_is_fork_repo(@project_url)
          return result unless result[:status]

          create_gitee_pull(branch, path, content_base64, message, pr_desc)
        else
          result = github_is_fork_repo(@project_url)
          return result unless result[:status]

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
          uri.path = uri.path.sub(/\.git$/, '')
          domain = uri&.normalized_host
          domain_name = domain.starts_with?('gitee.com') ? 'gitee' : 'github'
          if domain_name == 'gitee'
            result = gitee_is_fork_repo(@project_url)
            return result unless result[:status]
          else
            result = github_is_fork_repo(@project_url)
            return result unless result[:status]
          end
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
      project['community_org_url'] = @extra[:community_org_url] if @extra[:community_org_url]
      project['community_logo_url'] = @extra[:community_logo_url] if @extra[:community_logo_url]
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

  def duplicate_validate
    label = @project_url || @label
    if label.present?
      task = ProjectTask.find_by(project_name: label)
      if task.present?
        return {
          status: false,
          message: I18n.t('pull.duplicate'),
          report_url: "/analyze?label=#{label}&level=#{@level}"
        }
      end
    end
    { status: true }
  end

  def subject_validate
    return { status: false, message: I18n.t('users.subject_not_exist') } if @subject.blank?
    { status: true }
  end

  private

  def create_gitee_pull(branch, path, content_base64, message, pr_desc, sha: nil)
    result = gitee_create_branch(branch)
    return result unless result[:status]

    if sha
      result = gitee_put_file(path, message, content_base64, branch, sha)
      return result unless result[:status]
    else
      result = gitee_post_file(path, message, content_base64, branch)
      return result unless result[:status]
    end
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

  def create_github_pull(branch, path, content_base64, message, pr_desc, sha: nil)
    result = github_get_head_sha()
    return result unless result[:status]

    result = github_create_ref(branch, result[:sha])
    return result unless result[:status]

    result = github_put_file(path, message, content_base64, branch, sha: sha)
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

  def cacualte_sha(content)
    header = "blob #{content.bytesize}\0"
    combined = header + content
    Digest::SHA1.hexdigest(combined)
  end
end
