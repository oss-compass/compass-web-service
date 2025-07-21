# frozen_string_literal: true

class Gitcode2PullEnrich < GitcodeBase

  include BaseEnrich
  include Pull2Enrich

  def self.index_name
    'gitcode2-pulls_enriched'
  end


end
