# frozen_string_literal: true

class GiteeIssueEnrich
  include SearchFlip::Index

  def self.connection
    AuthSearchConn
  end

  def self.index_name
    'gitee_issues-enriched'
  end
end
