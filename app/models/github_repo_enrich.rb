# frozen_string_literal: true

class GithubRepoEnrich
  include SearchFlip::Index

  def self.connection
    AuthSearchConn
  end

  def self.index_name
    'github_repo-enriched'
  end
end
