# frozen_string_literal: true

class Gitcode2IssueEnrich < GitcodeBase

  include BaseEnrich

  def self.index_name
    'gitcode2-issues_enriched'
  end

end
