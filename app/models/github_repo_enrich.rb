# frozen_string_literal: true

class GithubRepoEnrich < GithubBase
  def self.index_name
    'github-repo_enriched'
  end
end
