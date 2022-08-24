# frozen_string_literal: true

class GithubRepo
  include SearchFlip::Index

  def self.connection
    AuthSearchConn
  end

  def self.index_name
    'github-repo_raw'
  end
end
