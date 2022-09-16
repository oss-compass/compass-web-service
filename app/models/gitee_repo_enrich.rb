# frozen_string_literal: true

class GiteeRepoEnrich < GiteeBase
  def self.index_name
    'gitee_repo-enriched'
  end
end
