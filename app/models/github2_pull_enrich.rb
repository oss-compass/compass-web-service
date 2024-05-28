# frozen_string_literal: true

class Github2PullEnrich < GiteeBase

  include BaseEnrich
  include Pull2Enrich

  def self.index_name
    'github2-pulls_enriched'
  end


end
