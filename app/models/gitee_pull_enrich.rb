# frozen_string_literal: true

class GiteePullEnrich
  include SearchFlip::Index

  def self.connection
    AuthSearchConn
  end

  def self.index_name
    'gitee_pulls-enriched'
  end
end
