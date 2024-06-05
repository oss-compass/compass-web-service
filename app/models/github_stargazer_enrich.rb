# frozen_string_literal: true

class GithubStargazerEnrich < GithubBase
  def self.index_name
    'github-stargazer_enriched'
  end
end
