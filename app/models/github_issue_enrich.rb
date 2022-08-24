# frozen_string_literal: true

class GithubIssueEnrich
  include SearchFlip::Index

  def self.connection
    AuthSearchConn
  end

  def self.index_name
    'github_enriched'
  end
end
