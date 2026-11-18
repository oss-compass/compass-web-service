# frozen_string_literal: true

class Gitee2IssueEnrich < GiteeBase

  include BaseEnrich

  def self.index_name
    'gitee2-issues_enriched'
  end

end
