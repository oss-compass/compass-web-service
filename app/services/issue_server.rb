# frozen_string_literal: true
class IssueServer
  include GiteeApplication
  include GithubApplication

  def initialize(opts = {})
    @repo_url = opts[:repo_url]
    @gitee_token = opts[:gitee_token]
    @github_token = opts[:github_token]
  end

  def create_gitee_issue(title, body)
    result = gitee_create_issue(@repo_url, @gitee_token, title, body)
    return result unless result[:status]
    { status: true, issue_url: result[:issue_url] }
  end

  def create_gitee_issue_comment(number, body)
    result = gitee_create_issue_comment(@repo_url, @gitee_token, number, body)
    return result unless result[:status]
    { status: true, message: result[:message] }
  end

  def create_github_issue(title, body)
    result = github_create_issue(@repo_url, @github_token, title, body)
    return result unless result[:status]
    { status: true, issue_url: result[:issue_url] }
  end


end
