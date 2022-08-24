# frozen_string_literal: true

class GiteeRepo
  include SearchFlip::Index

  def self.connection
    AuthSearchConn
  end

  def self.index_name
    'gitee_repo-raw'
  end
end
