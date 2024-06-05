# frozen_string_literal: true

class GithubForkEnrich < GithubBase
  def self.index_name
    'github-fork_enriched'
  end
end
