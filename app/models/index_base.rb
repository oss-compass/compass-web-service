# frozen_string_literal: true

class IndexBase
  include SearchFlip::Index
  def self.connection
    AuthSearchConn
  end
end
