# frozen_string_literal: true

class GithubEventEnrich < GithubBase
  def self.index_name
    'github-event_enriched'
  end
end
