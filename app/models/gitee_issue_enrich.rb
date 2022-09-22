# frozen_string_literal: true

class GiteeIssueEnrich < GiteeBase
  def self.index_name
    'gitee-issues_enriched'
  end
end
