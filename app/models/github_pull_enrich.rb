# frozen_string_literal: true

class GithubPullEnrich
  include SearchFlip::Index

  def self.connection
    AuthSearchConn
  end

  def self.index_name
    'github-pull_enriched'
  end
end
