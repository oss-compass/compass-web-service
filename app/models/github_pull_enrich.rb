# frozen_string_literal: true

class GithubPullEnrich < GithubBase
  def self.index_name
    'github-pulls_enriched'
  end
end
