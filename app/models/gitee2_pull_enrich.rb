# frozen_string_literal: true

class Gitee2PullEnrich < GiteeBase

  include BaseEnrich
  include Pull2Enrich

  def self.index_name
    'gitee2-pulls_enriched'
  end


end
