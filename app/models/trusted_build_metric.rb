class TrustedBuildMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_trusted_build"
  end


  def self.dimension
    'dev and build'
  end

  def self.scope
    'supply chain security'
  end

  def self.ident
    'trusted_build'
  end

  def self.text_ident
    'trusted_build'
  end

  def self.main_score
    'score'
  end



end
