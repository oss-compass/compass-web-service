# frozen_string_literal: true

class GithubGitEnrich < GithubBase

  include BaseEnrich
  include CommitEnrich

  def self.index_name
    'github-git_enriched'
  end
end
