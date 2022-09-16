# frozen_string_literal: true

class GiteePullEnrich < GiteeBase
  def self.index_name
    'gitee_pulls-enriched'
  end
end
