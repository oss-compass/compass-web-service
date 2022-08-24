# frozen_string_literal: true

class GiteeRepoEnrich
  include SearchFlip::Index

  def self.connection
    AuthSearchConn
  end

  def self.index_name
    'gitee_repo-enriched'
  end
end
