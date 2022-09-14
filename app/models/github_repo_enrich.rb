# frozen_string_literal: true

class GithubRepoEnrich < GithubBase
  def self.index_name
    'github_repo-enriched'
  end
end
