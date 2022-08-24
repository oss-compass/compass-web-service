class GithubIssue
  include SearchFlip::Index

  def self.connection
    AuthSearchConn
  end

  def self.index_name
    'github_raw'
  end
end
