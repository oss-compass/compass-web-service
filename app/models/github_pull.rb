class GithubPull
  include SearchFlip::Index

  def self.connection
    AuthSearchConn
  end

  def self.index_name
    'github-pull_raw'
  end
end
