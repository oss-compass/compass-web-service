# frozen_string_literal: true

class GithubIssueEnrich < GithubBase
  def self.index_name
    'github-issues_enriched'
  end
end
