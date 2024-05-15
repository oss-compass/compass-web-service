# frozen_string_literal: true

class GiteeGitEnrich < GiteeBase

  include BaseEnrich
  include CommitEnrich
  def self.index_name
    'gitee-git_enriched'
  end
end
