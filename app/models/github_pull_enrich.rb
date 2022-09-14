# frozen_string_literal: true

class GithubPullEnrich < GithubBase
  def self.index_name
    'github-pull_enriched'
  end
end
