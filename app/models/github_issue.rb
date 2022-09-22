# frozen_string_literal: true

class GithubIssue < GithubBase
  def self.index_name
    'github-issues_raw'
  end
end
