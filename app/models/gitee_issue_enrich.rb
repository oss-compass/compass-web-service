# frozen_string_literal: true

class GiteeIssueEnrich < GiteeBase
  def self.index_name
    'gitee_issues-enriched'
  end
end
