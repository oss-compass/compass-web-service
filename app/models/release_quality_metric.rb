class ReleaseQualityMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_release_quality"
  end


  def self.dimension
    'release and maintenance'
  end

  def self.scope
    'supply chain security'
  end

  def self.ident
    'release_quality'
  end

  def self.text_ident
    'release_quality'
  end

  def self.main_score
    'score'
  end



end
