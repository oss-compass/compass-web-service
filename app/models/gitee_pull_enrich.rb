# frozen_string_literal: true

class GiteePullEnrich < GiteeBase
  def self.index_name
    'gitee-pulls_enriched'
  end
end
