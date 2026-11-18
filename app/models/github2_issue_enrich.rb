# frozen_string_literal: true

class Github2IssueEnrich < GithubBase

  include BaseEnrich

  def self.index_name
    'github2-issues_enriched'
  end

end
