class CoreRetentionMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_core_retention"
  end



  def self.dimension
    'developer retention'
  end

  def self.scope
    'developer journey'
  end

  def self.ident
    'core_retention'
  end

  def self.text_ident
    'core_retention'
  end

  def self.main_score
    'score'
  end

end
