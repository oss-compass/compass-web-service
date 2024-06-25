# frozen_string_literal: true
class IssueServer
  include GiteeApplication
  include GithubApplication

  def initialize(opts = {})
    @repo_url = opts[:repo_url]
  end

  def create_gitee_issue(gitee_token, title, body)
    result = gitee_create_issue(@repo_url, gitee_token, title, body)
    Rails.logger.info "create_gitee_issue: #{result}"
    return result unless result[:status]
    { status: true, issue_url: result[:issue_url] }
  end

  def create_github_issue(github_token, title, body)
    result = github_create_issue(@repo_url, github_token, title, body)
    return result unless result[:status]
    { status: true, issue_url: result[:issue_url] }
  end


end
